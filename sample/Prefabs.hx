import hcb.comp.snd.AudioListener;
import hcb.comp.*;
import hcb.math.Vector2;
import h2d.Tile;
import hcb.comp.col.*;

class Prefabs {
    public static function player(): Array<Component> {
        var ap: AnimationPlayer = new AnimationPlayer("Animations", 1);
        ap.addAnimation("Cube", Tile.fromColor(0xFF00000, 32, 32), 1, AnimationPlayer.Origin.center);

        var playerCollisionShape: CollisionPolygon = new CollisionPolygon("Collision");
        playerCollisionShape.setVerticies(
            [
                new Vector2(-16, -16),
                new Vector2(15, -16),
                new Vector2(15, 15),
                new Vector2(-16, 15)
            ]
        );

        var player: Array<Component> = [
            new Transform2D("Position"),
            new PlayerController("Controller"),
            ap,
            playerCollisionShape,
            new Navigation("Nav"),
            new Camera("Cam", true),
            new AudioListener("Listener", true)
        ];

        return player;
    }
}