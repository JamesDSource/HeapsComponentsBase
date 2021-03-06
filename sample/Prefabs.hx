import hcb.Origin.OriginPoint;
import hcb.comp.*;
import hcb.math.Vector2;
import h2d.Tile;
import hcb.comp.col.*;

class Prefabs {
    public static function player(entity: ldtk.Entity): Array<Component> {
        var ap: AnimationPlayer = new AnimationPlayer("Animations", 1);
        ap.addAnimation("Cube", Tile.fromColor(0xFF00000, 32, 32), 1, OriginPoint.center);

        var player: Array<Component> = [
            new Transform2D("Position"),
            new PlayerController("Controller"),
            ap,
            new Navigation("Nav")
        ];

        return player;
    }
}