package hcb.comp.anim;

import h2d.Anim;
import h2d.Tile;
import hcb.Origin;
import VectorMath;

class Animation extends Anim {
    public var flipX(default, set): Bool = false;
    public var flipY(default, set): Bool = false;

    public var originPoint(default, set): OriginPoint = OriginPoint.topLeft;
    public var originOffsetX(default, set): Float = 0;
    public var originOffsetY(default, set): Float = 0;

    private function set_flipX(flipX: Bool): Bool {
        if(this.flipX != flipX) {
            for(frame in frames) {
                frame.flipX();
            }
            this.flipX = flipX;
        }
        return flipX;
    }

    private function set_originPoint(originPoint: OriginPoint): OriginPoint {
        if(this.originPoint != originPoint) {
            this.originPoint = originPoint;
            setOrigin();
        }
        return originPoint;
    }

    private function set_originOffsetX(originOffsetX: Float): Float {
        if(this.originOffsetX != originOffsetX) {
            this.originOffsetX = originOffsetX;
            setOrigin();
        }
        return originOffsetX;
    }

    private function set_originOffsetY(originOffsetY: Float): Float {
        if(this.originOffsetY != originOffsetY) {
            this.originOffsetY = originOffsetY;
            setOrigin();
        }
        return originOffsetY;
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
        super(animFrames, speed);
        this.originPoint = originPoint;
        this.originOffsetX = originOffsetX;
        this.originOffsetY = originOffsetY;
    }

    private function setOrigin() {
        for(animFrame in frames) {
            var w = animFrame.width;
            var h = animFrame.height;

            // * Setting the origin
            var offset: Vec2 = Origin.getOriginOffset(originPoint, vec2(w, h));
            animFrame.dx = offset.x + originOffsetX;
            animFrame.dy = offset.y + originOffsetY;
        }
    }
}