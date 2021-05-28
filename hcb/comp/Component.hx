package hcb.comp;

import h2d.Object;


enum PauseMode {
    Idle;
    Resume;
    Inherit;
}

class Component {
    public var name: String;
    public var pauseMode: PauseMode = PauseMode.Idle;

    public var parentEntity: hcb.Entity = null;
    // ^ Read only, should not be changed manually
    public var attached(get, null): Bool;

    public var room: Room = null;
    public var project(get, null): Project;

    public var updateable(default, set): Bool = true;

    private function get_attached(): Bool {
        return parentEntity != null;
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
    private dynamic function init() {}

    // & Called automatically by the Project class every frame if updateable
    @:allow(hcb.Entity.update)
    private dynamic function update() {}

    // & Called when the component is removed from an entity
    @:allow(hcb.Entity.removeComponent)
    private dynamic function onRemoved() {}

    // & Called when the parent entity is added to a room
    @:allow(hcb.Room.addEntity)
    private dynamic function addedToRoom() {}
    
    // & Called when the parent entity is removed from a room
    @:allow(hcb.Room.removeEntity, hcb.Entity.removeComponent)
    private dynamic function removedFromRoom() {}
}