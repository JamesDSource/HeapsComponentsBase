package hcb;

// & Project acts as a manager for the rooms
class Project {
    public var app(default, null): hxd.App;

    public var room(default, set): Room = null;
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
            app.setScene(room.scene);
            room.roomSet();
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
        if(app.s2d != room.scene) {
            app.setScene(room.scene);
        }
    }
}