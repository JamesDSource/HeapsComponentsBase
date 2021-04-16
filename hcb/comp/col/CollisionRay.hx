package hcb.comp.col;

import hcb.comp.col.CollisionShape.Bounds;
import VectorMath;

class CollisionRay extends CollisionShape {
    // ^ Cast points are set in local coordinates
    private var castPoint: Vec2 = vec2(0, 0);
    private var castPointTransformed: Vec2 = vec2(0, 0);

    public var scaleX: Float = 1;
    public var scaleY: Float = 1;
    private var scale: Vec2 = vec2(1, 1);
    public var infinite: Bool;

    private override function get_bounds(): Bounds {
        var pos = getAbsPosition();

        return {
            min: vec2(Math.min(pos.x, pos.x + castPointTransformed.x), Math.min(pos.y, pos.y + castPointTransformed.y)),
            max: vec2(Math.max(pos.x, pos.x + castPointTransformed.x), Math.max(pos.y, pos.y + castPointTransformed.y))
        }
    }

    public function new(name: String, infinite: Bool, ?offset: Vec2) {
        super(name, offset);  
        this.infinite = infinite;
    }

    public function getCastPoint(): Vec2 {
        return castPoint.clone();
    }

    public function getTransformedCastPoint(): Vec2 {
        return castPointTransformed.clone();
    }

    public function getGlobalTransformedCastPoint(): Vec2 {
        return castPointTransformed + getAbsPosition();
    }

    public function setCastPoint(point: Vec2) {
        castPoint = point.clone();
        updateTransformations();
    }

    public function setCastPointGlobal(point: Vec2) {
        castPoint = point - getAbsPosition();
        updateTransformations();
    }

    // && Sets 'castPointTransformed' to 'castPoint' rotated and scaled
    private function updateTransformations() {
        castPointTransformed = castPoint;
        castPointTransformed = castPointTransformed*scale;
        updateCollisionCells();
    }
}