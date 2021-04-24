import hxd.Window;
import hcb.Project;
import hcb.LdtkEntities;

class Main extends hxd.App {
    private var proj: hcb.Project;
    public static var room1: Room;
    public static var room2: Room;
    
    override function init() {
        var levels = new Levels();

        // * Project init
        proj = new Project(this);
        room1 = new Room(levels.all_levels.Test);
        room2 = new Room(levels.all_levels.Test2); 

        LdtkEntities.ldtkEntityPrefabs["Player"] = Prefabs.player;

        room1.build();
        room2.build();

        proj.room = room1;
    }  

    override function update(delta: Float) {
        var targetDelta: Float = 1/60;
        var deltaMult = Math.min(delta/targetDelta, 3);
        proj.update(deltaMult);
        room1.collisionWorld.representShapes(room1.scene, 4);
    }

    static function main() {
        hxd.Res.initLocal();
        new Main();
    }
}