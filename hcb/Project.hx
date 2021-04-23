package hcb;

// & Project acts as a manager for the rooms
class Project {
    private var app: hxd.App;

    public var room(default, set): Room = null;

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
            room.update(delta);
        }
    }

    public function updateRoomScene() {
        if(app.s2d != room.scene) {
            app.setScene(room.scene);
        }
    }
}