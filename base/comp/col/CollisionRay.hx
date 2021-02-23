package base.comp.col;

import base.math.Vector2;

class CollisionRay extends CollisionShape {
    // ^ Cast points are set in local coordinates
    private var castPoint: Vector2 = new Vector2();
    private var castPointTransformed: Vector2 = new Vector2();

    private var rayScale: Vector2 = new Vector2(1, 1);
    public var infinite: Bool;

    public function new(infinite: Bool) {
        super();  
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
        castPoint = point;
        calculateTransformations();
    }

    // && Sets 'castPointTransformed' to 'castPoint' rotated and scaled
    private function calculateTransformations() {
        castPointTransformed = castPoint;
        castPointTransformed = castPointTransformed.mult(rayScale);
        radius = castPoint.getLength();
    }

    public function setRayScale(scaleFactor: Vector2) {
        rayScale = scaleFactor;
        calculateTransformations();
    }
}