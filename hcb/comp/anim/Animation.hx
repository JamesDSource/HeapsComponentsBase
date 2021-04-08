package hcb.comp.anim;

import h2d.Anim;
import h2d.Tile;
import hcb.Origin;
import hcb.math.Vector2;

class Animation extends Anim {
    public var flipX(default, set): Bool = false;
    public var flipY(default, set): Bool = false;

    private function set_flipX(flipX: Bool): Bool {
        if(this.flipX != flipX) {
            for(frame in frames) {
                frame.flipX();
            }
            this.flipX = flipX;
        }
        return flipX;
    }

    private function set_flipY(flipY: Bool): Bool {
        if(this.flipY != flipY) {
            for(frame in frames) {
                frame.flipY();
            }
            this.flipY = flipY;
        }
        return flipY;
    }

    public function new(strip: Tile, frames: Int, speed: Float = 15, originPoint: OriginPoint = OriginPoint.topLeft, originOffsetX: Float = 0, originOffsetY: Float = 0) {
        var animFrames: Array<Tile> = strip.split(frames);
        
        for(animFrame in animFrames) {
            var w = animFrame.width;
            var h = animFrame.height;

            // * Setting the origin
            var offset: Vector2 = Origin.getOriginOffset(originPoint, new Vector2(w, h));
            animFrame.dx = offset.x;
            animFrame.dy = offset.y;
        }
        super(animFrames, speed);
    }
}