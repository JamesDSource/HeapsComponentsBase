import base.comp.col.CollisionPolygon;
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
        proj.navigationGrids["Player"] = grid;

        // * Player
        var ap: AnimationPlayer = new AnimationPlayer("Animations", 1);
        ap.addAnimation("Cube", Tile.fromColor(0xFF00000, 32, 32), 1);

        var playerCollisionShape: CollisionPolygon = new CollisionPolygon("Collision");
        playerCollisionShape.setVerticies(
            [
                new Vector2(0, 0),
                new Vector2(31, 0),
                new Vector2(31, 31),
                new Vector2(0, 31)
            ]
        );

        player = [
            new Transform2D("Position", new Vector2(100, 100)),
            new PlayerController("Controller"),
            ap,
            playerCollisionShape,
            new Navigation("Nav")
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