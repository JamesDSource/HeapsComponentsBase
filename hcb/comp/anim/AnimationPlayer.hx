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
    public var renderParent(default, set): h2d.Object;

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

    public function new(name: String, ?renderParent: h2d.Object, layer: Int = 0) {
        // * renderParent should be null if you want it to just be added to the scene
        super(name);
        this.renderParent = renderParent;
        this.layer = layer;
    }

    public override function init() {
        if(renderParent == null) {
            renderParent = project.scene;
        }
    }

    public override function update(delta: Float) { 
        var transform: Transform2D = cast parentEntity.getComponentOfType(Transform2D);
        
        if(transform != null) {
            var position: Vec2 = transform.getPosition();
            for(animationSlot in animationSlots) {
                if(animationSlot.animation != null) {
                    // * Updating the position
                    animationSlot.animation.x = position.x;
                    animationSlot.animation.y = position.y;
                }
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
}