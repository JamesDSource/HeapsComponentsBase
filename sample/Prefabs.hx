import hcb.comp.anim.AnimationPlayer;
import hcb.Origin.OriginPoint;
import hcb.comp.*;
import h2d.Tile;
import hcb.comp.col.*;

class Prefabs {
    public static function player(entity: ldtk.Entity): Array<Component> {
        var playerEnt: Levels.Entity_Player = cast entity;

        var player: Array<Component> = [
            new Transform2D("Position"),
            new PlayerController("Controller"),
            new CollisionAABB("AABB", 10, 20, OriginPoint.bottomCenter),
            new AnimationPlayer("Animations", 1)
        ];
        
        return player;
    }
}