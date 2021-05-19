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

    public function new(level: Levels.Levels_Level, usesPhysics: Bool = true, collisionCellSize: Float = 256) {
        super(usesPhysics, collisionCellSize);
        this.level = level;
    }

    public override function build() {
        LdtkEntities.ldtkAddEntities(this, cast level.l_Entities.getAllUntyped());
        
        var rend = level.l_Collisions.render();
        scene.add(rend, 0);

        collisionGridMap[1] = IndexGrid.slopeBuild.bind(SlopeFace.TopLeft, _, _);
        collisionGridMap[2] = IndexGrid.slopeBuild.bind(SlopeFace.TopRight, _, _);

        var collisionIndexGrid = IndexGrid.ldtkTilesConvert(level.l_Collisions);
        var staticCollisionShapes = IndexGrid.convertToCollisionShapes(collisionIndexGrid, ["Static"], collisionGridMap);
        for(shape in staticCollisionShapes) {
            collisionWorld.addShape(shape);
            var body = new Body("Body", {mass: 0, elasticity: 1, shape: shape});
            physicsWorld.addBody(body);
        }
        
        var grav = new hcb.physics.Gravity();
        for(body in physicsWorld.getBodies()) {
            physicsWorld.forceRegistry.add(grav, body);
        }

        scene.scaleMode = ScaleMode.Stretch(cast 1920/2, cast 1080/2);
    }
}