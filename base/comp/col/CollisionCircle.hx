package base.comp.col;

import base.math.Vector2;

class CollisionCircle extends CollisionShape {
    public function new(name: String) {
        super(name);
    }
    
    public function setRadius(radius: Float) {
        this.radius = radius;
    }

    public override function getBounds(): {topLeft: Vector2, bottomRight: Vector2} {
        var pos = getAbsPosition(),
            tl = new Vector2(pos.x - radius/2, pos.y - radius/2),
            br = new Vector2(pos.x + radius/2, pos.y + radius/2);
        
        return {topLeft: tl, bottomRight: br};
    }
}