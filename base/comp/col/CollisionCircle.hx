package base.comp.col;

class CollisionCircle extends CollisionShape {
    public function new(name: String) {
        super(name);
    }
    
    public function setRadius(radius: Float) {
        this.radius = radius;
    }
}