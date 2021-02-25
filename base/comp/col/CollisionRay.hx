package base.comp.col;

import base.math.Vector2;

class CollisionRay extends CollisionShape {
    // ^ Cast points are set in local coordinates
    private var castPoint: Vector2 = new Vector2();
    private var castPointTransformed: Vector2 = new Vector2();

    private var rayScale: Vector2 = new Vector2(1, 1);
    public var infinite: Bool;

    public function new(name: String, infinite: Bool) {
        super(name);  
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

    public override function getBounds(): {topLeft: Vector2, bottomRight: Vector2} {
        var pos = getAbsPosition();
        return {
            topLeft: new Vector2(Math.min(pos.x, pos.x + castPoint.x), Math.min(pos.y, pos.y + castPoint.y)),
            bottomRight: new Vector2(Math.max(pos.x, pos.x + castPoint.x), Math.max(pos.y, pos.y + castPoint.y))
        };
    }
}