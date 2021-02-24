import base.math.Vector2;
import base.PathfindingGrid;
import base.Project;
import h2d.Tile;
import base.comp.*;

class Main extends hxd.App {

    private var proj: base.Project;

    private var player: Array<base.comp.Component> = [];

    private var grid: PathfindingGrid;

    override function init() {
        // * Project init
        proj = new Project();
        setScene(proj.scene);

        // * Pathfinding grid
        grid = new PathfindingGrid(32, new base.math.Vector2(50, 50));

        // * Player
        var ap: AnimationPlayer = new AnimationPlayer(1);
        ap.addAnimation("Cube", Tile.fromColor(0xFF00000, 32, 32), 1);

        var playerTransform = new Transform2D();
        playerTransform.position.set(100, 100);

        player = [
            playerTransform,
            new PlayerController(),
            ap
        ];

        proj.addEntity(player);
    }

    override function update(delta: Float) {
        proj.update(delta);
    }

    static function main() {
        hxd.Res.initLocal();
        new Main();
    }
}