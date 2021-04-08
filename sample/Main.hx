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
    private var proj: hcb.Project;
    private var player: Array<hcb.comp.Component> = [];

    private var collisionGridMap: Map<Int, Vector2 -> Int -> CollisionShape> = new Map<Int, Vector2 -> Int -> CollisionShape>();
    
    override function init() {
        var levels = new Levels();

        // * Project init
        proj = new Project(this);
        setScene(proj.scene);


        proj.ldtkEntityPrefabs["Player"] = Prefabs.player;
        proj.ldtkAddEntities(cast levels.all_levels.Test.l_Entities.getAllUntyped());

        var rend = levels.all_levels.Test.l_Collisions.render();
        proj.renderables.add(rend, 0);

        collisionGridMap[1] = function(origin: Vector2, tileSize: Int): CollisionShape {
            var shape: CollisionPolygon = new CollisionPolygon("poly");
            shape.offset = origin;
            shape.setVerticies(
                [
                    new Vector2(tileSize - 1, 0),
                    new Vector2(tileSize - 1, tileSize - 1),
                    new Vector2(0, tileSize - 1)
                ]
            );
            return shape;
        }

        collisionGridMap[2] = function(origin: Vector2, tileSize: Int): CollisionShape {
            var shape: CollisionPolygon = new CollisionPolygon("poly");
            shape.offset = origin;
            shape.setVerticies(
                [
                    new Vector2(0, 0),
                    new Vector2(tileSize - 1, tileSize - 1),
                    new Vector2(0, tileSize - 1)
                ]
            );
            return shape;
        }
        proj.ldtkAddCollisionLayer(levels.all_levels.Test.l_Collisions, ["Static"], null, collisionGridMap);
    }  

    override function update(delta: Float) {
        proj.update(delta);
    }

    static function main() {
        hxd.Res.initLocal();
        new Main();
    }
}