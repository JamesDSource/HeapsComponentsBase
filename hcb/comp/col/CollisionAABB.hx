package hcb.comp.col;
import hcb.comp.col.CollisionShape.Bounds;
import hcb.Origin;
import VectorMath;

class CollisionAABB extends CollisionShape {

    public var origin: OriginPoint = OriginPoint.TopLeft;

    public var width(default, set): Float;
    public var height(default, set): Float;
    public var transformedWidth(default, null): Float;
    public var transformedHeight(default, null): Float;
    public var scaleX(default, set): Float = 1;
    public var scaleY(default, set): Float = 1;
    private var scale: Vec2 = vec2(1, 1);

    public var vertices(get, null): Array<Vec2>;

    private inline function set_width(width: Float): Float {
        this.width = width;
        updateTransformations();
        return width;
    }

    private inline function set_height(height: Float): Float {
        this.height = height;
        updateTransformations();
        return height;
    }

    private inline function set_scaleX(scaleX: Float): Float {
        this.scaleX = scaleX;
        scale.x = scaleX;
        updateTransformations();
        return scaleX;
    }

    private inline function set_scaleY(scaleY: Float): Float {
        this.scaleY = scaleY;
        scale.y = scaleY;
        updateTransformations();
        return scaleY;
    }

    private inline function get_vertices(): Array<Vec2> {
        var boxBounds = bounds;
        
        return [
            boxBounds.min,
            vec2(boxBounds.min.x, boxBounds.max.y),
            boxBounds.max,
            vec2(boxBounds.max.x, boxBounds.min.y)
        ];
    }

    private override function get_bounds(): Bounds {
        var tl = getAbsPosition() + Origin.getOriginOffset(origin, vec2(transformedWidth, transformedHeight));
        return {
            min: vec2(tl.x, tl.y),
            max: vec2(tl.x + transformedWidth - 1, tl.y + transformedHeight - 1)
        }
    }

    private override function get_center(): Vec2 {
        var tl = getAbsPosition() + Origin.getOriginOffset(origin, vec2(transformedWidth, transformedHeight));
        return tl + vec2(transformedWidth - 1, transformedHeight - 1)/2;
    }

    public function new(name: String, width: Float, height: Float, ?origin: OriginPoint, ?offset: Vec2) {
        super(name, offset);

        this.width = width;
        this.height = height;
        if(origin != null) {
            this.origin = origin;
            updateTransformations();
        }
    }

    public function updateTransformations() {
        transformedWidth = width * scale.x;
        transformedHeight = height * scale.y;
        updateCollisionCells();
    }
}