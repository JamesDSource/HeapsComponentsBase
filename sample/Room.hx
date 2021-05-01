import h2d.Scene.ScaleMode;
import hcb.LdtkEntities;
import hcb.comp.col.*;
import VectorMath;
import hcb.IndexGrid;

class Room extends hcb.Room {
    private var level: Levels.Levels_Level;

    private var collisionGridMap: Map<Int, Vec2 -> Float -> CollisionShape> = [];
    
    public function new(level: Levels.Levels_Level, usesPhysics: Bool = true, collisionCellSize: Float = 256) {
        super(collisionCellSize, usesPhysics);
        this.level = level;
    }

    public override function build() {
        scene.add(physicsWorld.graphics, 5);

        scene.scaleMode = ScaleMode.Stretch(cast 1920/2, cast 1080/2);

        LdtkEntities.ldtkAddEntities(this, cast level.l_Entities.getAllUntyped());
        
        var rend = level.l_Collisions.render();
        scene.add(rend, 0);

        collisionGridMap[1] = function(origin: Vec2, tileSize: Float): CollisionShape {
            var verts: Array<Vec2> = [
                vec2(tileSize - 1, 0),
                vec2(0, tileSize - 1),
                vec2(tileSize - 1, tileSize - 1)
            ];
            var shape: CollisionPolygon = new CollisionPolygon("poly", verts);
            shape.offsetX = origin.x;
            shape.offsetY = origin.y;
            return shape;
        }

        collisionGridMap[2] = function(origin: Vec2, tileSize: Float): CollisionShape {
            var verts: Array<Vec2> = [
                vec2(0, tileSize - 1),
                vec2(0, 0),
                vec2(tileSize - 1, tileSize - 1)
            ];
            var shape: CollisionPolygon = new CollisionPolygon("poly", verts);
            shape.offsetX= origin.x;
            shape.offsetY= origin.y;
            return shape;
        }
        var collisionIndexGrid = IndexGrid.ldtkTilesConvert(level.l_Collisions);
        var staticCollisionShapes = IndexGrid.convertToCollisionShapes(collisionIndexGrid, ["Static"], collisionGridMap);
        for(shape in staticCollisionShapes) {
            collisionWorld.addShape(shape);
        }
    }
}