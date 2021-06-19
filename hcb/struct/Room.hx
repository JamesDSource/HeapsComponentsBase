package hcb.struct;

class Room {
    @:allow(hcb.struct.Project)
    public var project(default, null): Project;
    // ^ Do not set this manually, should only be accessed by Project class

    private var entities: Array<Entity> = [];

    public var paused(default, set): Bool = false;
    private var onPauseListeners: Array<(Bool) -> Void> = [];

    private var accumulator: Float = 0;

    private var timers: Array<Timer> = [];

    private function set_paused(paused: Bool) {
        if(this.paused != paused) {
            this.paused = paused;

            // * Call the on pause event
            for(listener in onPauseListeners) {
                listener(paused);
            }
        }
        return paused;
    }

    public function new() {
        
    }

    // & Completely clears out the room
    public function clear() {
        for(entity in entities.copy()) {
            removeEntity(entity);
        }

        timers = [];
    }

    public dynamic function build() {}

    public function rebuild() {
        clear();
        build();
        resync();
    }

    @:allow(hcb.struct.Project.update)
    private function update(delta: Float, targetFrameRate: Float, targetPhysicsFrameRate: Float): Float {
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
        
        // * Timers
        for(timer in timers) {
            timer.countDown(delta, paused);
        }

        // * Normal update loop
        InputManager.get().catchInputs();
        accumulator += delta;
        var frames: Int = 0;
        while(accumulator >= 1/targetFrameRate) {
            onUpdate();
            for(entity in entities) {
                entity.update(paused);
            }
            accumulator -= 1/targetFrameRate;
            frames++;
        }
        if(frames > 0)
            InputManager.get().clearInputs();

        return delta;
    }

    public function resync() {
        accumulator = 0;
    }

    // & Event called when a normal update is called
    private function onUpdate() {}

    // & Event called when the room is added to a project
    @:allow(hcb.struct.Project.set_room)
    private function roomSet() {}

    // & Event called when the room is removed from the project
    @:allow(hcb.struct.Project.set_room)
    private function roomRemoved() {}

    // & Event called when entity is added to room
    private function entityAdded(entity: Entity) {}

    // & Event called when entity is removed from room
    private function entityremoved(entity: Entity) {}

    // & Adding an entity to the room
    public function addEntity(entity: Entity): Bool {
        // * Check if the entity is already in another room
        if(entity.room != null) {
            entity.room.removeEntity(entity);
        }

        if(!entities.contains(entity)) {
            entities.push(entity);
            entity.roomIn = this;

            for(comp in entity.getComponents()) {
                comp.addedToRoom();
            }

            entityAdded(entity);

            return true;
        }

        return false;
    }

    // & Removing an entity from a room
    public function removeEntity(entity: Entity): Bool {
        for(comp in entity.getComponents()) {
            comp.removedFromRoom();
        }
        
        entity.roomIn = null;
        
        var result: Bool = entities.remove(entity);
        if(result)
            entityremoved(entity);
        return result; 
    }

    // & Checks if a specified entity is in this room
    public function hasEntity(entity: Entity): Bool {
        return entities.contains(entity);
    }

    // & Returns all the entities in the room
    public function getEntities(): Array<Entity> {
        return entities.copy();
    }

    public function addTimer(timer: Timer) {
        timers.push(timer);
    }

    public function removeTimer(timer: Timer): Bool {
        return timers.remove(timer);
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