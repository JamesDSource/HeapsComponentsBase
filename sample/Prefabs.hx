import hcb.comp.anim.AnimationPlayer;
import hcb.Origin.OriginPoint;
import hcb.comp.*;
import hcb.comp.col.*;
import VectorMath;

class Prefabs {
    public static function player(entity: ldtk.Entity): Array<Component> {
        var playerEnt: Levels.Entity_Player = cast entity;

        var player: Array<Component> = [
            new Transform2D("Position"),
            new PlayerController("Controller"),
            new CollisionAABB("AABB", 10, 20, OriginPoint.BottomCenter),
            new AnimationPlayer("Animations", null, 1)
        ];
        
        return player;
    }
}