package hcb.comp;

import h2d.Object;
import hcb.struct.*;
import VectorMath;

class Component {
    public var name: String;
    public var pauseState: hcb.Pause.PauseState = Idle;

    @:allow(hcb.Entity)
    private var parentEntity(default, set): Entity = null;
    public var parent(get, null): Entity;
    public var parent2d(default, null): Entity2D;
    public var parent3d(default, null): Entity;
    public var attached(get, null): Bool;

    @:allow(hcb.Entity)
    private var roomIn(default, set): Room = null;
    public var room(get, null): Room;
    public var room2d(default, null): Room2D;
    public var room3d(default, null): Room3D;
    public var project(get, null): Project;

    public var updateable(default, set): Bool = true;

    private function set_parentEntity(parentEntity: Entity): Entity {
        parent2d = Std.isOfType(parentEntity, Entity2D) ? cast(parentEntity, Entity2D) : null;

        return this.parentEntity = parentEntity;
    }

    private inline function get_parent(): Entity {
        return parentEntity;
    }

    private inline function get_attached(): Bool {
        return parentEntity != null;
    }
    

    private function set_roomIn(roomIn: Room): Room {
        room2d = null;
        room3d = null;

        if(Std.isOfType(roomIn, Room2D))
            room2d = cast roomIn;
        else if(Std.isOfType(roomIn, Room3D))
            room3d = cast roomIn;

        this.roomIn = roomIn;
        return roomIn;
    }

    private inline function get_room(): Room {
        return roomIn;
    }
    
    private function get_project(): Project {
        if(room != null) {
            return room.project;
        }
        return null;
    }

    private function set_updateable(updateable: Bool): Bool {
        if(parentEntity != null && this.updateable != updateable) {
            var hasAsUpdateable: Bool = parentEntity.updatableComponents.contains(this);

            if(updateable) {
                if(!hasAsUpdateable) {
                    parentEntity.updatableComponents.push(this);
                }
            }
            else if(hasAsUpdateable) {
                parentEntity.updatableComponents.remove(this);
            }
        }
        return updateable;
    }

    public function new(name: String) {
        this.name = name;
    }

    // & called when the component is added to an entity
    @:allow(hcb.Entity.addComponent, hcb.Entity.addComponents)
    private function init() {}

    // & Called automatically by the Project class every frame if updateable
    @:allow(hcb.Entity.update)
    private function update() {}

    // & Called when the component is removed from an entity
    @:allow(hcb.Entity.removeComponent)
    private function onRemoved() {}

    // & Called when the parent entity is added to a room
    @:allow(hcb.struct.Room.addEntity)
    private function addedToRoom() {}
    
    // & Called when the parent entity is removed from a room
    @:allow(hcb.struct.Room.removeEntity, hcb.Entity.removeComponent)
    private function removedFromRoom() {}
}