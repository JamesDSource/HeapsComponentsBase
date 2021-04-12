package hcb.comp.col;
import hcb.comp.col.CollisionShape.Bounds;
import hcb.Origin;
import hcb.math.Vector2;
class CollisionAABB extends CollisionShape {

    public var origin: OriginPoint = OriginPoint.topLeft;

    public var width(default, set): Float;
    public var height(default, set): Float;
    public var transformedWidth(default, null): Float;
    public var transformedHeight(default, null): Float;
    public var scaleX(default, set): Float = 1;
    public var scaleY(default, set): Float = 1;
    private var scale: Vector2 = new Vector2(1, 1);

    private function set_width(width: Float): Float {
        this.width = width;
        updateTransformations();
        return width;
    }

    private function set_height(height: Float): Float {
        this.height = height;
        updateTransformations();
        return height;
    }

    private function set_scaleX(scaleX: Float): Float {
        this.scaleX = scaleX;
        scale.x = scaleX;
        updateTransformations();
        return scaleX;
    }

    private function set_scaleY(scaleY: Float): Float {
        this.scaleY = scaleY;
        scale.y = scaleY;
        updateTransformations();
        return scaleY;
    }

    private override function get_bounds(): Bounds {
        var tl = getAbsPosition().add(Origin.getOriginOffset(origin, new Vector2(transformedWidth, transformedHeight)));
        return {
            min: new Vector2(tl.x, tl.y),
            max: new Vector2(tl.x + transformedWidth - 1, tl.y + transformedHeight - 1)
        }
    }

    public function new(name: String, width: Float, height: Float, ?origin: OriginPoint) {
        super(name);

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