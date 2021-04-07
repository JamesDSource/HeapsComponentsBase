package hcb.comp;

import h2d.Bitmap;
import h2d.Object;
import h2d.Anim;
import h2d.Tile;
import hcb.Origin;
import hcb.math.Vector2;

class AnimationPlayer extends Component {
    public override function update(delta: Float) { 
        var transform: Transform2D = cast parentEntity.getComponentOfType(Transform2D);
        
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

    public function addAnimation(name: String, tile: Tile, frames: Int, originPoint: OriginPoint = OriginPoint.topLeft, originOffsetX: Float = 0, originOffsetY: Float = 0) {
        var animFrames: Array<Tile> = tile.split(frames); 
        
        for(animFrame in animFrames) {
            var w = animFrame.width;
            var h = animFrame.height;

            // * Setting the origin
            var offset = Origin.getOriginOffset(originPoint, new Vector2(w, h));
            animFrame.dx = offset.x;
            animFrame.dy = offset.y;
        }
        var newAnim = new Anim(animFrames);
        animations[name] = newAnim;
    }
}