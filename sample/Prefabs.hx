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

    public static function physicsCircle(entity: ldtk.Entity): Array<Component> {
        var circleEnt: Levels.Entity_PhysicsCircle = cast entity;

        var mass = Math.random()*15 + 1;

        var col = CollisionPolygon.rectangle("rect", mass, mass, OriginPoint.Center);
        //var col = new CollisionCircle("circle", mass);

        var circle: Array<Component> = [
            col,
            new Body("Physics", {shape: col, mass: mass, velocity: vec2(0, (-1 + Math.random()*2)), elasticity: 1})
        ];
        
        return circle;
    }
}