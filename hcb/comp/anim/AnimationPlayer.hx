package hcb.comp.anim;

import hcb.comp.anim.Animation;
import VectorMath;

private typedef AnimationSlot = {
    animation: Animation,
    layer: Int
}

class AnimationPlayer extends Component {
    private var animationSlots: Map<String, AnimationSlot> = new Map<String, AnimationSlot>();
    private var animationLayers: h2d.Layers = new h2d.Layers();
    public var layer(default, set): Int = 0;

    public var autoPause: Bool;
    // ^ When set to true, will automatically pause and unpause all animations when the room pauses or unpauses

    private function set_layer(layer: Int): Int {
        if(parentEntity != null) {
            parentEntity.layers.removeChild(animationLayers);
            parentEntity.layers.add(animationLayers, layer);
        }

        this.layer = layer;
        return layer;
    }

    public function new(name: String = "Animation Player", layer: Int = 0, autoPause: Bool = true) {
        // * renderParent should be null if you want it to just be added to the scene
        super(name);
        this.layer = layer;
        this.autoPause = autoPause;
    }

    private override function init() {
        parentEntity.layers.add(animationLayers, layer);
    }

    private override function onRemoved() {
        parentEntity.layers.removeChild(animationLayers);
    }

    private override function addedToRoom() {
        room.onPauseEventSubscribe(onPause);
        if(autoPause) {
            onPause(room.paused);
        }
    }

    private override function removedFromRoom() {
        room.onPauseEventRemove(onPause);
        if(autoPause && room.paused) {
            onPause(false);
        }
    }

    private override function update() {       
        var position: Vec2 = parentEntity.getPosition2d();
        for(animationSlot in animationSlots) {
            if(animationSlot.animation != null) {
                // * Updating the position
                animationSlot.animation.x = position.x;
                animationSlot.animation.y = position.y;

                // * Calling the on frame event
                var frame: Int = Std.int(animationSlot.animation.currentFrame);
                if(animationSlot.animation.previousFrame != frame) {
                    animationSlot.animation.onFrameEventCall(frame);
                    animationSlot.animation.previousFrame = frame;
                }
            }
        }
    }

    public function addAnimationSlot(name: String, layer: Int, ?animation: Animation) {
        removeAnimationSlot(name);
        animationSlots[name] = {animation: null, layer: layer};
        if(animation != null)
            setAnimationSlot(name, animation);
    }

    public function removeAnimationSlot(name: String) {
        if(animationSlots.exists(name) && animationSlots[name].animation != null) {
            animationLayers.removeChild(animationSlots[name].animation);
        }

        animationSlots.remove(name);
    }

    public function setAnimationSlot(name: String, animation: Animation) {
        if(animationSlots.exists(name)) {
            if(animationSlots[name].animation == animation) {
                return;
            }

            if(animationSlots[name].animation != null) {
                animationLayers.removeChild(animationSlots[name].animation);
            }

            animationSlots[name].animation = animation;
            animationLayers.add(animation, animationSlots[name].layer);

            animation.previousFrame = Std.int(animation.currentFrame);
        }
    }

    public function getAnimation(slot: String): Animation {
        if(animationSlots.exists(slot)) {
            return animationSlots[slot].animation;
        }
        return null;
    }

    public function getAnimations(): Array<Animation> {
        var result: Array<Animation> = [];
        for(animSlot in animationSlots) {
            if(animSlot.animation == null)
                continue;

            result.push(animSlot.animation);
        }
        return result;
    }

    private function onPause(paused: Bool) {
        if(autoPause) {
            for(slot in animationSlots) {
                if(slot.animation == null)
                    continue;

                slot.animation.pause = paused;
            }
        }
    }
}