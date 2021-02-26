import h2d.Bitmap;
import ldtk.Layer_Tiles;
import ldtk.Level;
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
        var levels = new Levels();

        // * Project init
        proj = new Project();
        setScene(proj.scene);

        // * Pathfinding grid
        grid = new PathfindingGrid(32, new base.math.Vector2(50, 50));
        proj.navigationGrids["Player"] = grid;

        proj.ldtkEntityPrefabs["Player"] = Prefabs.player;
        proj.ldtkAddEntities(cast levels.all_levels.Test.l_Entities.getAllUntyped());

        var rend = levels.all_levels.Test.l_Collisions.render();
        proj.renderables.add(rend, 0);

        proj.ldtkAddCollisionLayer(levels.all_levels.Test.l_Collisions, ["Static"]);
        grid.addCollisionShapesTag(proj.collisionWorld, "Static");
    }

    override function update(delta: Float) {
        proj.update(delta);
    }

    static function main() {
        hxd.Res.initLocal();
        new Main();
    }
}