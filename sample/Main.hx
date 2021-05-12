import hcb.physics.Gravity;
import hcb.comp.col.Collisions;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.col.CollisionCircle;
import hcb.comp.col.CollisionAABB;
import hxd.Key;
import hcb.Project;
import hcb.LdtkEntities;

class Main extends hxd.App {
    private var proj: hcb.Project;
    private var room: Room;
    
    override function init() {
        Gravity.gravity.y = 0.1;

        var levels = new Levels();

        // * Project init
        proj = new Project(this);
        room = new Room(levels.all_levels.Test);

        LdtkEntities.ldtkEntityPrefabs["Player"] = Prefabs.player;
        LdtkEntities.ldtkEntityPrefabs["PhysicsBody"] = Prefabs.physicsBody;

        room.build();

        proj.room = room;
    }  

    override function update(delta: Float) {
        proj.update(delta);

        if(Key.isPressed(Key.ESCAPE)) {
            proj.room.paused = !proj.room.paused;
        }

        if(Key.isPressed(Key.R)) {
            room.rebuild();
        }

        room.collisionWorld.representShapes(room.scene, 3);
    }

    static function main() {
        hxd.Res.initLocal();
        new Main();
    }
}