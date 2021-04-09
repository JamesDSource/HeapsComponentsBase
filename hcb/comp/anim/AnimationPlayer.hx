package hcb.comp.anim;

import hcb.comp.anim.Animation;
import hcb.math.Vector2;

private typedef AnimationSlot = {
    animation: Animation,
    layer: Int
}

class AnimationPlayer extends Component {
    private var animationSlots: Map<String, AnimationSlot> = new Map<String, AnimationSlot>();
    private var animationLayers: h2d.Layers = new h2d.Layers();
    private var layer: Int;

    public function new(name: String, layer: Int) {
        super(name);
        this.layer = layer;
    }

    public override function init() {
        project.renderables.add(animationLayers, layer);
    }

    public override function update(delta: Float) { 
        var transform: Transform2D = cast parentEntity.getComponentOfType(Transform2D);
        
        if(transform != null) {
            var position: Vector2 = transform.getPosition();
            for(animationSlot in animationSlots) {
                if(animationSlot.animation != null) {
                    // * Updating the position
                    animationSlot.animation.x = position.x;
                    animationSlot.animation.y = position.y;
                }
            }
        }
        else {
            trace("AnimationPlayer needs a transform to draw");
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