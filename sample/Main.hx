import hcb.*;
import hxd.Window;
import VectorMath;
import hcb.comp.col.*;

class Main extends hxd.App {
    private var proj: hcb.Project;
    private var room1: Room;
    private var room2: Room;

    private var collisionGridMap: Map<Int, Vec2 -> Float -> CollisionShape> = new Map<Int, Vec2 -> Float -> CollisionShape>();
    
    override function init() {
        Window.getInstance().vsync = false;

        var levels = new Levels();

        // * Project init
        proj = new Project(this);
        room1 = new Room();
        proj.room = room1;


        LdtkEntities.ldtkEntityPrefabs["Player"] = Prefabs.player;
        LdtkEntities.ldtkAddEntities(room1, cast levels.all_levels.Test2.l_Entities.getAllUntyped());

        var rend = levels.all_levels.Test2.l_Collisions.render();
        room1.scene.add(rend, 0);

        collisionGridMap[1] = function(origin: Vec2, tileSize: Float): CollisionShape {
            var verts: Array<Vec2> = [
                vec2(tileSize - 1, 0),
                vec2(tileSize - 1, tileSize - 1),
                vec2(0, tileSize - 1)
            ];
            var shape: CollisionPolygon = new CollisionPolygon("poly", verts);
            shape.offsetX = origin.x;
            shape.offsetY = origin.y;
            return shape;
        }

        collisionGridMap[2] = function(origin: Vec2, tileSize: Float): CollisionShape {
            var verts: Array<Vec2> = [
                vec2(0, 0),
                vec2(tileSize - 1, tileSize - 1),
                vec2(0, tileSize - 1)
            ];
            var shape: CollisionPolygon = new CollisionPolygon("poly", verts);
            shape.offsetX= origin.x;
            shape.offsetY= origin.y;
            return shape;
        }
        var collisionIndexGrid = IndexGrid.ldtkTilesConvert(levels.all_levels.Test2.l_Collisions);
        var staticCollisionShapes = IndexGrid.convertToCollisionShapes(collisionIndexGrid, ["Static"], collisionGridMap);
        for(shape in staticCollisionShapes) {
            room1.collisionWorld.addShape(shape);
        }
    }  

    override function update(delta: Float) {
        var targetDelta: Float = 1/60;
        var deltaMult = Math.min(delta/targetDelta, 3);
        proj.update(deltaMult);
    }

    static function main() {
        hxd.Res.initLocal();
        new Main();
    }
}