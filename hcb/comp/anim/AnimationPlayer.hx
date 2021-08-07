package hcb.comp.anim;

import hcb.struct.Room;
import hcb.comp.anim.Animation;
import VectorMath;

private typedef AnimationSlot = {
    animation: Animation,
    layer: Int
}

class AnimationPlayer extends TransformComponent2D {
    private var animationSlots: Map<String, AnimationSlot> = new Map<String, AnimationSlot>();
    public var animationLayers(default, null): h2d.Layers = new h2d.Layers();
    public var layer(default, set): Int = 0;

    private function set_layer(layer: Int): Int {
        if(parent2d != null) {
            parent2d.layers.removeChild(animationLayers);
            parent2d.layers.add(animationLayers, layer);
        }

        this.layer = layer;
        return layer;
    }

    public function new(layer: Int = 0, name: String = "Animation Player") {
        // * renderParent should be null if you want it to just be added to the scene
        super(name);
        this.layer = layer;

        transform.onTranslated =    (position) -> animationLayers.setPosition(position.x, position.y);
        transform.onRotated =       (rotation) -> animationLayers.rotation = rotation;
        transform.onScaled =        (scale) -> {animationLayers.scaleX = scale.x; animationLayers.scaleY = scale.y;};
    }

    private override function init() {
        if(parent2d != null)
            parent2d.layers.add(animationLayers, layer);
    }

    private override function onRemoved() {
        if(parent2d != null)
            parent2d.layers.removeChild(animationLayers);
    }

    private override function update() {
        for(animationSlot in animationSlots) {
            if(animationSlot.animation.stop)
                continue;

            var dt = room.overrideTargetFramerate == null ? Room.targetFramerate : room.overrideTargetFramerate;
            animationSlot.animation.step(1/dt);
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
            if(animationSlots[name].animation == animation)
                return;

            if(animationSlots[name].animation != null)
                animationLayers.removeChild(animationSlots[name].animation);

            animationSlots[name].animation = animation;
            animationLayers.add(animation, animationSlots[name].layer);
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
}