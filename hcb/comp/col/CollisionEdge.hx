package hcb.comp.col;

import hcb.comp.col.CollisionShape.Bounds;
import h2d.Graphics;
import VectorMath;

using hcb.math.Vector;

// Unlike the other collision shapes, this one is not moved at all
// by the transform instance. The CollisionEdge is meant for static
// geometry that does not change much
class CollisionEdge extends CollisionShape {
    private var v1: Vec2 = null;
    // ^ Ghost vertex 1
    private var v2: Vec2 = null;
    private var v3: Vec2 = null;
    private var v4: Vec2 = null;
    // ^ Ghost vertex 2

    private var normal: Vec2 = null;

    private override function get_bounds():Bounds {
        return {
            min: vec2(Math.min(v2.x, v3.x), Math.min(v2.y, v3.y)),
            max: vec2(Math.max(v2.x, v3.x), Math.max(v2.y, v3.y))
        };
    }

    private override function get_center():Vec2 {
        return (v2 + v3)/2;
    }

    public function new(v1: Vec2, v2: Vec2, leftNormal: Bool = false, name: String = "Collision Edge") {
        super(name);
        setVerticies(v1, v2, leftNormal);

        // Since the transform doesn't affect the edge,
        // we don't need this event call
        transform.onTranslated = (pos) -> null;
    }

    public function setVerticies(v1: Vec2, v2: Vec2, ?ghost1: Vec2, ?ghost2: Vec2, leftNormal: Bool = false) {
        if(ghost1 != null)
            this.v1 = ghost1.clone();
        this.v2 = v1.clone();
        this.v3 = v2.clone();
        if(ghost2 != null)
            this.v4 = ghost2.clone();

        normal = normalize(v2 - v1);
        normal = leftNormal ? normal.crossLeft() : normal.crossRight();
    }

    public function setGhosts(ghost1: Vec2, ghost2: Vec2) {
        v1 = ghost1 == null ? null : ghost1.clone();
        v4 = ghost2 == null ? null : ghost2.clone();        
    }

    public override function represent(g:Graphics, ?color:Int, alpha:Float = 1.0) {
        super.represent(g, color, alpha);
        g.moveTo(v2.x, v2.y);
        g.lineTo(v3.x, v3.y);
    }
}