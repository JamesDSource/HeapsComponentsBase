package hcb.comp.col;

import hcb.comp.col.CollisionShape.Bounds;
import hcb.math.Vector2;

class CollisionRay extends CollisionShape {
    // ^ Cast points are set in local coordinates
    private var castPoint: Vector2 = new Vector2();
    private var castPointTransformed: Vector2 = new Vector2();

    public var scaleX: Float = 1;
    public var scaleY: Float = 1;
    private var scale: Vector2 = new Vector2(1, 1);
    public var infinite: Bool;

    private override function get_bounds(): Bounds {
        var pos = getAbsPosition();

        return {
            min: new Vector2(Math.min(pos.x, pos.x + castPointTransformed.x), Math.min(pos.y, pos.y + castPointTransformed.y)),
            max: new Vector2(Math.max(pos.x, pos.x + castPointTransformed.x), Math.max(pos.y, pos.y + castPointTransformed.y))
        }
    }

    public function new(name: String, infinite: Bool, ?offset: Vector2) {
        super(name, offset);  
        this.infinite = infinite;
    }

    public function getCastPoint(): Vector2 {
        return castPoint.clone();
    }

    public function getTransformedCastPoint(): Vector2 {
        return castPointTransformed.clone();
    }

    public function getGlobalTransformedCastPoint(): Vector2 {
        return castPointTransformed.add(getAbsPosition());
    }

    public function setCastPoint(point: Vector2) {
        castPoint = point.clone();
        updateTransformations();
    }

    public function setCastPointGlobal(point: Vector2) {
        castPoint = point.subtract(getAbsPosition());
        updateTransformations();
    }

    // && Sets 'castPointTransformed' to 'castPoint' rotated and scaled
    private function updateTransformations() {
        castPointTransformed = castPoint;
        castPointTransformed = castPointTransformed.mult(scale);
        updateCollisionCells();
    }
}