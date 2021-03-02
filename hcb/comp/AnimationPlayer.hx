package hcb.comp;

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

class AnimationPlayer extends Component {
    public override function update(delta: Float) { 
        var transform: Transform2D = cast parentEntity.getSingleComponentOfType(Transform2D);
        
        if(transform != null) {
            for(animation in animations) {
                // * Adding the animation to the correct layer
                if(animation.parent == null) {
                    parentEntity.project.renderables.add(animation, layer);
                }

                // * Updating the position
                animation.x = transform.position.x;
                animation.y = transform.position.y;
            }
        }
        else {
            trace("AnimationPlayer needs a transform to draw");
        }
    }

    public var animations: Map<String, Anim> = [];
    private var layer: Int;

    public function new(name: String, layer: Int) {
        super(name);
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
}