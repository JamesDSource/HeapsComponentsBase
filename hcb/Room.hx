package hcb;

class Room {
    public var project: Project;
    // ^ Do not set this manually, should only be accessed by Project class

    public var scene(default, null): h2d.Scene;
    private var entities: Array<Entity> = [];
    public var collisionWorld(default, null): CollisionWorld;
    public var physicsWorld(default, null): hcb.physics.PhysicsWorld;
    public var usesPhysics: Bool;

    public var paused(default, set): Bool = false;
    private var onPauseListeners: Array<(Bool) -> Void> = [];

    private var accumulator: Float = 0;
    private var physicsAccumulator: Float = 0;

    public function set_paused(paused: Bool) {
        if(this.paused != paused) {
            this.paused = paused;

            // * Call the on pause event
            for(listener in onPauseListeners) {
                listener(paused);
            }
        }
        return paused;
    }

    public function new(usesPhysics: Bool = false, collisionCellSize: Float = 256) {
        scene = new h2d.Scene();
        collisionWorld = new CollisionWorld(collisionCellSize);
        physicsWorld = new hcb.physics.PhysicsWorld(collisionWorld);
        this.usesPhysics = usesPhysics;
    }

    // & Completely clears out the room
    public function clear() {
        for(entity in entities.copy()) {
            removeEntity(entity);
        }

        collisionWorld.clear();
        physicsWorld.clear();

        scene.dispose();
        scene = new h2d.Scene();
        if(project != null) {
            project.updateRoomScene();
        }
    }

    public dynamic function build() {}

    public function rebuild() {
        clear();
        build();
        resync();
    }

    public function update(delta: Float, targetFrameRate: Float, targetPhysicsFrameRate: Float) {
        // * Frame snapping
        var threshold: Float  = 0.0002;
        if(Math.abs(delta - 1/targetFrameRate) < threshold) {
            delta = 1/targetFrameRate;
        }
        else if(Math.abs(delta - 1/targetPhysicsFrameRate) < threshold) {
            delta = 1/targetPhysicsFrameRate;
        }
        else if(Math.abs(delta - 1/30) < threshold) {
            delta = 1/30;
        }
        else if(Math.abs(delta - 1/60) < threshold) {
            delta = 1/60;
        }
        else if(Math.abs(delta - 1/120) < threshold) {
            delta = 1/120;
        }

        // * Normal update loop
        accumulator += delta;
        while(accumulator >= 1/targetFrameRate) {
            onUpdate();
            for(entity in entities) {
                entity.update(paused);
            }
            accumulator -= 1/targetFrameRate;
        }

        // * Physics loop
        if(usesPhysics) {
            physicsAccumulator += delta;
            while(physicsAccumulator >= 1/targetPhysicsFrameRate) {
                onPhysicsUpdate();
                physicsWorld.update();
                physicsAccumulator -= 1/targetPhysicsFrameRate;
            }
        }

    }

    public function resync() {
        accumulator = 0;
        physicsAccumulator = 0;
    }

    // & Event called when a normal update is called
    public dynamic function onUpdate() {}

    // & Event called when a physics update is called
    public dynamic function onPhysicsUpdate() {}

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

    // & Functions for the onPause event
    public function onPauseEventSubscribe(callBack: (Bool) -> Void) {
        if(!onPauseListeners.contains(callBack)) {
            onPauseListeners.push(callBack);
        }
    }

    public function onPauseEventRemove(callBack: (Bool) -> Void) {
        onPauseListeners.remove(callBack);
    }
}