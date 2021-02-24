package base.comp;

import h2d.Bitmap;
import h2d.Object;
import h2d.Anim;
import h2d.Tile;

enum Origin {
    topLeft;
    topCenter;
    topRight;
    centerLeft;
    center;
    centerRight;
    bottomLeft;
    bottomCenter;
    bottomRight;
}

class AnimationPlayer implements Component {
    public var parentEntity: Entity = null;
    public var updateable: Bool = true;

    public function init() {
        
    }

    public function update(delta: Float) { 
        var transforms: Array<Component> = parentEntity.getComponentsOfType(Transform2D);
        
        if(transforms.length > 0) {
            for(animation in animations) {
                // * Adding the animation to the correct layer
                if(animation.parent == null) {
                    parentEntity.project.renderables.add(animation, layer);
                }

                // * Updating the position
                var transform: Transform2D = cast(transforms[0], Transform2D);
                animation.x = transform.position.x;
                animation.y = transform.position.y;
            }
        }
        else {
            trace("AnimationPlayer needs a transform to draw");
        }
    }

    public var animations: Map<String, Anim> = [];
    private var flipped: Bool = false;

    private var layer: Int;

    public function new(layer: Int) {
        this.layer = layer;
    }

    public function addAnimation(name: String, tile: Tile, frames: Int, originPoint: Origin = Origin.topLeft, originOffsetX: Float = 0, originOffsetY: Float = 0) {
        var animFrames: Array<Tile> = tile.split(frames); 
        
        for(animFrame in animFrames) {
            var w = animFrame.width;
            var h = animFrame.height;

            // * Setting the origin
            switch(originPoint) {
                case Origin.topLeft:
                    animFrame.dx = originOffsetX;
                    animFrame.dy = originOffsetY;
                case Origin.topCenter:
                    animFrame.dx = -w/2 + originOffsetX;
                    animFrame.dy = originOffsetY;
                case Origin.topRight:
                    animFrame.dx = -w + originOffsetX;
                    animFrame.dy = originOffsetY;
                case Origin.centerLeft:
                    animFrame.dx = originOffsetX;
                    animFrame.dy = -h/2 + originOffsetY;
                case Origin.center:
                    animFrame.dx = -w/2 + originOffsetX;
                    animFrame.dy = -h/2 + originOffsetY;
                case Origin.centerRight:
                    animFrame.dx = -w + originOffsetX;
                    animFrame.dy = -h/2 + originOffsetY;
                case Origin.bottomLeft:
                    animFrame.dx = originOffsetX;
                    animFrame.dy = -h + originOffsetY;
                case Origin.bottomCenter:
                    animFrame.dx = -w/2 + originOffsetX;
                    animFrame.dy = -h + originOffsetY;
                case Origin.bottomRight:
                    animFrame.dx = -w + originOffsetX;
                    animFrame.dy = -h + originOffsetY;
            }
        }
        var newAnim = new Anim(animFrames);
        animations[name] = newAnim;
    }

    public function isFlipped(): Bool {
        return flipped;
    }

    public function setFlipped(flipped) {
        if(this.flipped != flipped) {
            for(animKey in animations.keys()) {
                var anim: Anim = animations[animKey];
                var frames: Array<Tile> = anim.frames;
                for(frame in frames) {
                    frame.flipX();
                }
            }
            this.flipped = flipped;
        }
    }
}