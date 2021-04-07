import h2d.Graphics;
import h2d.Tile;
import h2d.Bitmap;
import hcb.Origin.OriginPoint;
import hcb.math.Vector2;
import hcb.pathfinding.PathfindingGrid;
import hcb.Project;
import hcb.comp.*;
import hcb.comp.col.*;

class Main extends hxd.App {
    var t: Float = 0;

    private var proj: hcb.Project;
    private var player: Array<hcb.comp.Component> = [];
    private var grid: PathfindingGrid;

    var bbox: CollisionAABB;
    var bboxG: Graphics;

    public var poly: CollisionPolygon;
    public var polyG: Graphics;
    
    override function init() {
        var levels = new Levels();

        // * Project init
        proj = new Project(this);
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