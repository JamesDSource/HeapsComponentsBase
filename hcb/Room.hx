package hcb;

import hcb.comp.Component;

enum PauseMode {
    Idle;
    Resume;
}

class Room {
    public var project: Project;
    // ^ Do not set this manually, should only be accessed by Project class

    public var scene(default, null): h2d.Scene;
    private var entities: Array<Entity> = [];
    public var collisionWorld(default, null): CollisionWorld;

    public var paused: Bool = false;

    public function new(collisionCellSize: Float = 256) {
        scene = new h2d.Scene();
        collisionWorld = new CollisionWorld(collisionCellSize);
    }

    // & Completely clears out the room
    public function clear() {
        for(entity in entities.copy()) {
            removeEntity(entity);
        }

        collisionWorld.clear();

        scene.dispose();
        scene = new h2d.Scene();
        if(project != null) {
            project.updateRoomScene();
        }
    }

    public dynamic function build() {}

    public function update(delta: Float) {
        for(entity in entities) {
            entity.update(delta);
        }
    }

    // & Event called when the room is added to a project
    public dynamic function roomSet() {}

    // & Event called when the room is removed from the project
    public dynamic function roomRemoved() {}

    // & Adding an entity to the room
    public function addEntity(entity: Entity) {
        // * Check if the entity is already in another room
        if(entity.room != null) {
            entity.room.removeEntity(entity);
        }

        if(!entities.contains(entity)) {
            entities.push(entity);
            entity.room = this;

            for(comp in entity.getComponents()) {
                comp.addedToRoom();
            }
        }
    }

    // & Removing an entity from a room
    public function removeEntity(entity: Entity): Bool {
        for(comp in entity.getComponents()) {
            comp.removedFromRoom();
        }
        
        entity.room = null;
        return entities.remove(entity);
    }

    // & Checks if a specified entity is in this room
    public function hasEntity(entity: Entity): Bool {
        return entities.contains(entity);
    }

    // & Returns all the entities in the room
    public function getEntities(): Array<Entity> {
        return entities.copy();
    }
}