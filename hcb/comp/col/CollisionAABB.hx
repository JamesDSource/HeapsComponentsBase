package hcb.comp.col;
import h2d.Graphics;
import hcb.comp.col.CollisionShape.Bounds;
import hcb.Origin;
import VectorMath;

class CollisionAABB extends CollisionShape {

    public var origin: OriginPoint = OriginPoint.TopLeft;

    public var width(default, set): Float;
    public var height(default, set): Float;
    public var transformedWidth(default, null): Float;
    public var transformedHeight(default, null): Float;

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
            max: vec2(tl.x + transformedWidth, tl.y + transformedHeight)
        }
    }

    private override function get_center(): Vec2 {
        var tl = getAbsPosition() + Origin.getOriginOffset(origin, vec2(transformedWidth, transformedHeight));
        return tl + vec2(transformedWidth, transformedHeight)/2;
    }

    public function new(width: Float, height: Float, ?origin: OriginPoint, name: String = "Collision AABB") {
        super(name);
        
        this.width = width;
        this.height = height;
        if(origin != null) {
            this.origin = origin;
            updateTransformations();
        }
    }

    public function updateTransformations() {
        var scale = transform.getScale();
        transformedWidth = width * scale.x;
        transformedHeight = height * scale.y;
        updateCollisionCells();
    }

    public override function represent(g:Graphics, ?color: Int, alpha: Float = 1.) {
        super.represent(g, color, alpha);
        var bounds: Bounds = bounds;
        g.drawRect(bounds.min.x, bounds.min.y, bounds.max.x - bounds.min.x, bounds.max.y - bounds.min.y);
    }
}