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
        this.origin = origin;

        scale = new Vector2(1, 1);

        updateTransformations();
    }

    public function setSize(width: Float, height: Float) {
        this.width = width;
        this.height = height;
        updateTransformations();
    }

    public function setScale(xScale: Float, yScale: Float) {
        scale.x = xScale;
        scale.y = yScale;
        updateTransformations();
    }

    public function updateTransformations() {
        transformedWidth = width * scale.x;
        transformedHeight = height * scale.y;
        radius = Math.max(transformedWidth, transformedHeight);
    }

    public override function getBounds(): {topLeft: Vector2, bottomRight: Vector2} {
        var tl = getAbsPosition().add(Origin.getOriginOffset(origin, new Vector2(transformedWidth, transformedHeight)));
        return {topLeft: tl, bottomRight: tl.add(new Vector2(transformedWidth - 1, transformedHeight - 1))};
    }
}