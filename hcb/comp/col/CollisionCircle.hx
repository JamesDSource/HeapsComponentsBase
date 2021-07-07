package hcb.comp.col;

import h2d.Graphics;
import hcb.comp.col.CollisionShape.Bounds;
import VectorMath;

class CollisionCircle extends CollisionShape {
    public var radius(default, set): Float = 0;

    public function set_radius(radius: Float): Float {
        this.radius = radius;
        updateCollisionCells();
        return radius;
    }

    public function new(radius: Float = 10, ?offset: Vec2, name: String = "Collision Circle") {
        super(offset, name);
        this.radius = radius;
    }

    private override function get_bounds(): Bounds {
        var pos = getAbsPosition();
        return {
            min: vec2(pos.x - radius, pos.y - radius),
            max: vec2(pos.x + radius, pos.y + radius)
        }
    }

    public override function getSupportPoint(d:Vec2):Vec2 {
        return getAbsPosition() + d*radius;
    }

    public override function represent(g:Graphics, ?color: Int, alpha: Float = 1.) {
        super.represent(g, color, alpha);
        var pos = getAbsPosition();
        g.drawCircle(pos.x, pos.y, radius);
    }
} 