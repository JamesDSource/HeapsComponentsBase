import hcb.math.Vector2;
import hcb.PathfindingGrid;
import hcb.Project;
import hcb.comp.*;

class Main extends hxd.App {

    private var proj: hcb.Project;
    private var player: Array<hcb.comp.Component> = [];
    private var grid: PathfindingGrid;


    override function init() {
        var levels = new Levels();

        // * Project init
        proj = new Project();
        setScene(proj.scene);

        // * Pathfinding grid
        grid = new PathfindingGrid(32, new hcb.math.Vector2(50, 50));
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