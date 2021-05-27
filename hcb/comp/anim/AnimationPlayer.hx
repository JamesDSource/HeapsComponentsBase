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
    // ^ Layer does not do anything unless the renderParent is a h2d.Layers
    public var renderParent(default, set): h2d.Object;

    public var autoPause: Bool;
    // ^ When set to true, will automatically pause and unpause all animations when the room pauses or unpauses

    private function set_renderParent(renderParent: h2d.Object): h2d.Object {
        if(animationLayers.parent != null) {
            animationLayers.parent.removeChild(animationLayers);
        }
        
        if(renderParent != null) {
            if(Std.isOfType(renderParent, h2d.Layers)) {
                var layerParent: h2d.Layers = cast renderParent;
                layerParent.add(animationLayers, layer);
            }
            else {
                renderParent.addChild(animationLayers);
            }
        }

        this.renderParent = renderParent;
        return renderParent;
    }

    private function set_layer(layer: Int): Int {
        if(this.layer != layer && renderParent != null && Std.isOfType(renderParent, h2d.Layers)) {
            var layerParent: h2d.Layers = cast renderParent;
            layerParent.add(animationLayers, layer);
        }
        this.layer = layer;
        return layer;
    }

    public function new(name: String, ?renderParent: h2d.Object, layer: Int = 0, autoPause: Bool = true) {
        // * renderParent should be null if you want it to just be added to the scene
        super(name);
        this.renderParent = renderParent;
        this.layer = layer;
        this.autoPause = autoPause;
    }

    private override function addedToRoom() {
        if(renderParent == null) {
            renderParent = room.scene;
        }

        room.onPauseEventSubscribe(onPause);
        if(autoPause) {
            onPause(room.paused);
        }
    }

    private override function removedFromRoom() {
        if(renderParent == room.scene) {
            renderParent = null;
        }

        room.onPauseEventRemove(onPause);
        if(autoPause && room.paused) {
            onPause(false);
        }
    }

    private override function update() {       
        var position: Vec2 = parentEntity.getPosition();
        for(animationSlot in animationSlots) {
            if(animationSlot.animation != null) {
                // * Updating the position
                animationSlot.animation.x = position.x;
                animationSlot.animation.y = position.y;
            }
        }
    }

    public function addAnimationSlot(name: String, layer: Int) {
        removeAnimationSlot(name);
        animationSlots[name] = {animation: null, layer: layer};
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
        }
    }

    public function getAnimation(slot: String): Animation {
        if(animationSlots.exists(name)) {
            return animationSlots[name].animation;
        }
        return null;
    }

    public function getAnimations(): Array<Animation> {
        var result: Array<Animation> = [];
        for(animSlot in animationSlots) {
            result.push(animSlot.animation);
        }
        return result;
    }

    private function onPause(paused: Bool) {
        if(autoPause) {
            for(slot in animationSlots) {
                slot.animation.pause = paused;
            }
        }
    }
}