package hcb.struct;

// & Project acts as a manager for the rooms
class Project {
    public var app(default, null): hxd.App;

    public var room(default, set): Room = null;
    private var room2d: Room2D = null;
    private var room3d: Room3D = null;

    public var targetFrameRate: Float = 60;
    public var targetPhysicsFrameRate: Float = 60;

    private function set_room(room: Room): Room {
        if(this.room != room) {
            if(this.room != null) {
                this.room.roomRemoved();
                this.room.project = null;
            }

            this.room = room;
            room.project = this;
            room.roomSet();

            room2d = null;
            room3d = null;

            if(Std.isOfType(room, Room2D))
                room2d = cast room;
            else if(Std.isOfType(room, Room3D))
                room3d = cast room;

            updateRoomScene();
        }
        return room;
    }

    public function new(app: hxd.App) {
        this.app = app;
    }

    public function update(delta: Float) {
        if(room != null) {
            room.update(delta, targetFrameRate, targetPhysicsFrameRate);
        }
    }

    public function updateRoomScene() {
        if(room == null)
            return;

        if(room2d != null && app.s2d != room2d.scene) 
            app.setScene(room2d.scene);
        
        if(room3d != null && app.s3d != room3d.scene)
            app.setScene(room3d.scene);
    }
}