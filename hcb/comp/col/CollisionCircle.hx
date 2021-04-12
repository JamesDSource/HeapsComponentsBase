package hcb.comp.col;

import hcb.comp.col.CollisionShape.Bounds;
import hcb.math.Vector2;

class CollisionCircle extends CollisionShape {
    public var radius(default, set): Float = 0;

    public function set_radius(radius: Float): Float {
        this.radius = radius;
        updateCollisionCells();
        return radius;
    }

    private override function get_bounds(): Bounds {
        var pos = getAbsPosition();
        return {
            min: new Vector2(pos.x - radius/2, pos.y - radius/2),
            max: new Vector2(pos.x + radius/2, pos.y + radius/2)
        }
    }

    public function new(name: String, radius: Float = 10) {
        super(name);
        this.radius = radius;
    }
}