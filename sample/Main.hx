import hxd.Key;
import hxd.Window;
import hcb.Project;
import hcb.LdtkEntities;

class Main extends hxd.App {
    private var proj: hcb.Project;
    private var room: Room;
    
    override function init() {
        var levels = new Levels();

        // * Project init
        proj = new Project(this);
        room = new Room(levels.all_levels.Test);

        LdtkEntities.ldtkEntityPrefabs["Player"] = Prefabs.player;
        LdtkEntities.ldtkEntityPrefabs["PhysicsCircle"] = Prefabs.physicsCircle;

        room.build();

        proj.room = room;
    }  

    override function update(delta: Float) {
        var targetDelta: Float = 1/60;
        var deltaMult = Math.min(delta/targetDelta, 3);
        proj.update(deltaMult);

        if(Key.isPressed(Key.ESCAPE)) {
            proj.room.paused = !proj.room.paused;
        }

        room.collisionWorld.representShapes(room.scene, 3);
    }

    static function main() {
        hxd.Res.initLocal();
        new Main();
    }
}