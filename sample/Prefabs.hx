import hcb.comp.anim.AnimationPlayer;
import hcb.Origin.OriginPoint;
import hcb.comp.*;
import hcb.comp.col.*;
import VectorMath;

class Prefabs {
    public static function player(entity: ldtk.Entity): Array<Component> {
        var playerEnt: Levels.Entity_Player = cast entity;

        var player: Array<Component> = [
            new PlayerController("Controller"),
            new CollisionAABB("AABB", 10, 20, OriginPoint.BottomCenter),
            new AnimationPlayer("Animations", null, 1)
        ];
        
        return player;
    }

    public static function physicsBody(entity: ldtk.Entity): Array<Component> {
        var bodyEnt: Levels.Entity_PhysicsBody = cast entity;

        var mass = Math.random()*11 + 5;

        var col: CollisionShape;

        switch(bodyEnt.f_Shape) {
            case Levels.Enum_Shape.Circle:
                col = new CollisionCircle("circle", mass);
            case Levels.Enum_Shape.AABB:
                col = new CollisionAABB("aabb", mass, mass, OriginPoint.Center);
            case Levels.Enum_Shape.PolySquare:
                col = CollisionPolygon.rectangle("rect", mass, mass, OriginPoint.Center);
        }

        var circle: Array<Component> = [
            col,
            new Body("Physics", {shape: col, mass: mass, velocity: vec2(2*(-1 + Math.random()*2), 2*(-1 + Math.random()*2)), elasticity: 0.5, angularInertia: mass, dynamicFriction: 0.5, staticFriction: 0.5})
        ];
        
        return circle;
    }
}