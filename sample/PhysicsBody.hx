import hcb.comp.Body;
import hcb.comp.Component;
import hcb.Origin.OriginPoint;
import hcb.comp.col.*;
import hcb.Entity;
import VectorMath;

class PhysicsBody extends Entity {
    public function new(?position: Vec2, layer = 0, collider: CollisionShape, options: BodyOptions) {
        var components: Array<Component> = [
            collider,
            new Body("Physics", options)
        ];
        
        super(components, position, layer);
    }

    public static function ldtkConvert(entity: Levels.Entity_PhysicsBody): Entity {
        var mass = Math.random()*11 + 5;

        var col: CollisionShape;
        switch(entity.f_Shape) {
            case Levels.Enum_Shape.Circle:
                col = new CollisionCircle("circle", mass);
            case Levels.Enum_Shape.AABB:
                col = new CollisionAABB("aabb", mass, mass, Center);
            case Levels.Enum_Shape.PolySquare:
                col = CollisionPolygon.rectangle("rect", mass, mass, Center);
        }

        var options: BodyOptions = {shape: col, mass: mass, velocity: vec2(2*(-1 + Math.random()*2), 2*(-1 + Math.random()*2)), elasticity: 0.1, angularInertia: mass, dynamicFriction: 0.2, staticFriction: 0.2};        
        return new PhysicsBody(vec2(entity.pixelX, entity.pixelY), 0, col, options);
    }
}