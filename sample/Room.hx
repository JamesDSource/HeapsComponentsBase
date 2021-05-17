import hcb.Origin.OriginPoint;
import hxd.Key;
import hcb.comp.Body;
import h2d.Scene.ScaleMode;
import hcb.LdtkEntities;
import hcb.comp.col.*;
import VectorMath;
import hcb.IndexGrid;

class Room extends hcb.Room {
    private var level: Levels.Levels_Level;

    private var collisionGridMap: Map<Int, Vec2 -> Float -> CollisionShape> = [];
    
    private var shape1: CollisionPolygon;
    private var shape2: CollisionPolygon;
    private var shapeDrawer: h2d.Graphics = new h2d.Graphics();

    public function new(level: Levels.Levels_Level, usesPhysics: Bool = true, collisionCellSize: Float = 256) {
        super(usesPhysics, collisionCellSize);
        this.level = level;
    }

    public override function build() {
        scene.add(physicsWorld.graphics, 8);

        LdtkEntities.ldtkAddEntities(this, cast level.l_Entities.getAllUntyped());
        
        var rend = level.l_Collisions.render();
        scene.add(rend, 0);

        collisionGridMap[0] = function(origin: Vec2, tileSize: Float): CollisionShape {
            var verts: Array<Vec2> = [
                vec2(0, 0),
                vec2(0, tileSize - 1),
                vec2(tileSize - 1, tileSize - 1),
                vec2(tileSize - 1, 0)                
            ];
            var shape: CollisionPolygon = new CollisionPolygon("poly", verts);
            shape.offsetX = origin.x;
            shape.offsetY = origin.y;
            return shape;
        }

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
                vec2(0, 0),
                vec2(0, tileSize - 1),
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
            var body = new Body("Body", {mass: 0, elasticity: 1, shape: shape});
            physicsWorld.addBody(body);
        }
        
        var grav = new hcb.physics.Gravity();
        for(body in physicsWorld.getBodies()) {
            //physicsWorld.forceRegistry.add(grav, body);
        }

        scene.scaleMode = ScaleMode.Stretch(cast 1920/2, cast 1080/2);

        /*
        shape1 = CollisionPolygon.rectangle("Poly1", 64, 64, OriginPoint.Center);
        shape2 = CollisionPolygon.rectangle("Poly2", 64, 64, OriginPoint.Center);
        shape2.offsetX = shape2.offsetY = 200;
        shape1.offsetX = 180;
        shape1.offsetY = 245;

        scene.add(shapeDrawer, 1);
        */
    }

    public override function onUpdate() {
        /*
        if(Key.isDown(Key.W)) {
            shape1.offsetY -= 2;
        }
        if(Key.isDown(Key.A)) {
            shape1.offsetX -= 2;
        }
        if(Key.isDown(Key.S)) {
            shape1.offsetY += 2;
        }
        if(Key.isDown(Key.D)) {
            shape1.offsetX += 2;
        }
        if(Key.isDown(Key.Q)) {
            shape1.rotation += 2;
        }
        if(Key.isDown(Key.E)) {
            shape1.rotation -= 2;
        }

        shapeDrawer.clear();
        shapeDrawer.lineStyle(3, 0xFF0000);
        var verts1 = shape1.worldVertices;
        var verts2 = shape2.worldVertices;
        for(i in 0...verts1.length) {
            shapeDrawer.moveTo(verts1[i].x, verts1[i].y);
            shapeDrawer.lineTo(verts1[(i + 1)%verts1.length].x, verts1[(i + 1)%verts1.length].y);
        }
        for(i in 0...verts2.length) {
            shapeDrawer.moveTo(verts2[i].x, verts2[i].y);
            shapeDrawer.lineTo(verts2[(i + 1)%verts2.length].x, verts2[(i + 1)%verts2.length].y);
        }

        
        var colInfo = Collisions.test(shape1, shape2);
        if(colInfo.isColliding) {
            shapeDrawer.lineStyle(3, 0x00FF00, 0.5);
            var offset = colInfo.normal*colInfo.depth;
            for(i in 0...verts1.length) {
                shapeDrawer.moveTo(verts1[i].x - offset.x, verts1[i].y - offset.y);
                shapeDrawer.lineTo(verts1[(i + 1)%verts1.length].x - offset.x, verts1[(i + 1)%verts1.length].y - offset.y);
            }

            shapeDrawer.lineStyle(3, 0x00FFFF);
            for(point in colInfo.contactPoints) {
                shapeDrawer.drawCircle(point.x, point.y, 2);
            }
        }
        */
    }
}