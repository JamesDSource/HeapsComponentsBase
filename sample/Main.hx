import hcb.physics.Gravity;
import hxd.Key;
import hcb.Project;

class Main extends hxd.App {
    private var proj: hcb.Project;
    private var room: Room;
    
    override function init() {
        Gravity.gravity.y = 0.1;

        var levels = new Levels();

        // * Project init
        proj = new Project(this);
        room = new Room(levels.all_levels.Test);

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