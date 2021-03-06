package hcb.comp.col;
import hcb.Origin;
import hcb.math.Vector2;
class CollisionAABB extends CollisionShape {

    public var width(default, null): Float;
    public var height(default, null): Float;
    public var transformedWidth(default, null): Float;
    public var transformedHeight(default, null): Float;
    public var scale(default, null): Vector2;

    public var origin: OriginPoint;

    public function new(name: String, width: Float, height: Float, origin: OriginPoint = OriginPoint.topLeft) {
        super(name);

        this.width = width;
        this.height = height;
        transformedWidth = width;
        transformedHeight = height;

        this.origin = origin;
    }

    public function setSize(width: Float, height: Float) {
        this.width = width;
        this.height = height;
    }

    public function setScale(xScale: Float, yScale: Float) {
        scale.x = xScale;
        scale.y = yScale;
        transformedWidth = width * xScale;
        transformedHeight = height * yScale;
    }

    public override function getBounds(): {topLeft: Vector2, bottomRight: Vector2} {
        var tl = getAbsPosition().add(Origin.getOriginOffset(origin, new Vector2(transformedWidth, transformedHeight)));
        return {topLeft: tl, bottomRight: tl.add(new Vector2(transformedWidth, transformedHeight))};
    }
}