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

    public function new(radius: Float = 10, name: String = "Collision Circle") {
        super(name);
        this.radius = radius;
    }

    private override function get_bounds(): Bounds {
        var pos = transform.getPosition();
        return {
            min: vec2(pos.x - radius, pos.y - radius),
            max: vec2(pos.x + radius, pos.y + radius)
        }
    }

    public override function getSupportPoint(d:Vec2):Vec2 {
        return transform.getPosition() + d*radius;
    }

    public override function represent(g:Graphics, ?color: Int, alpha: Float = 1.) {
        super.represent(g, color, alpha);
        var pos = transform.getPosition();
        g.drawCircle(pos.x, pos.y, radius);

        var lineEnd: Vec2 = transform.getDirection()*radius + pos;
        g.moveTo(pos.x, pos.y);
        g.lineTo(lineEnd.x, lineEnd.y);
    }
} 