import hxd.Key;
import hcb.comp.Body;
import hcb.comp.col.*;
import VectorMath;
import hcb.IndexGrid;

class Room extends hcb.Room {
    private var level: Levels.Levels_Level;

    private var collisionGridMap: Map<Int, Vec2 -> Float -> CollisionShape> = [];
    private var shapeG: h2d.Graphics;

    public function new(level: Levels.Levels_Level, usesPhysics: Bool = true, collisionCellSize: Float = 256) {
        super(usesPhysics, collisionCellSize);
        this.level = level;
        shapeG = new h2d.Graphics();
        shapeG.alpha = 0.5;
    }

    public override function build() {
        createEntites();
        
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

        scene.add(shapeG, 3);
    }

    private override function onUpdate() {
        if(Key.isPressed(Key.ESCAPE)) 
            paused = !paused;

        if(Key.isPressed(Key.R)) 
            rebuild();

        if(Key.isPressed(Key.Q))
            Sys.exit(0);

        collisionWorld.representShapes(shapeG, true);
    }

    public function createEntites() {
        for(physicsEntity in level.l_Entities.all_PhysicsBody) {
            var ent = PhysicsBody.ldtkConvert(physicsEntity);
            addEntity(ent);   
        }

        for(playerEntity in level.l_Entities.all_Player) {
            var ent = PlayerEntity.ldtkConvert(playerEntity);
            addEntity(ent);   
        }
    }
}