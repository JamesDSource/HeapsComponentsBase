package hcb.struct;

class Room2D extends Room {
    public var scene(default, null): h2d.Scene;
    public var drawTo: h2d.Layers;
    // ^ The layers that parent the entity layers. Defaults to the scene
    
    public var collisionWorld(default, null): hcb.col.CollisionWorld;
    public var physicsWorld(default, null): hcb.physics.PhysicsWorld;
    public var usesPhysics: Bool;
    public var physicsPauseOnPause: Bool = true;
    private var physicsAccumulator: Float = 0;

    public function new(usesPhysics: Bool = false, collisionCellSize: Float = 256) {
        super();
        scene = new h2d.Scene();
        drawTo = scene;
        collisionWorld = new hcb.col.CollisionWorld(collisionCellSize);
        physicsWorld = new hcb.physics.PhysicsWorld(collisionWorld);
        this.usesPhysics = usesPhysics;
    }

    public override function clear() {
        super.clear();

        collisionWorld.clear();
        physicsWorld.clear();

        scene.dispose();
        scene = new h2d.Scene();
        drawTo = scene;

        if(project != null) {
            project.updateRoomScene();
        }
    }

    private override function update(delta:Float, targetFrameRate:Float, targetPhysicsFrameRate:Float): Float {
        delta = super.update(delta, targetFrameRate, targetPhysicsFrameRate);

        // * Physics loop
        if(!usesPhysics) 
            return delta;

        physicsAccumulator += delta;
        while(physicsAccumulator >= 1/targetPhysicsFrameRate) {
            if(!paused || !physicsPauseOnPause) {
                onPhysicsUpdate();
                physicsWorld.update();
            }
            physicsAccumulator -= 1/targetPhysicsFrameRate;
        }

        return delta;
    }

    public override function resync() {
        super.resync();
        physicsAccumulator = 0;
    }

    public override function addEntity(entity:Entity): Bool {
        var added = super.addEntity(entity);
        if(!Std.isOfType(entity, Entity2D))
            return added;

        var entity2d = cast(entity, Entity2D);

        if(added && entity2d.parentOverride == null)
            drawTo.add(entity2d.layers, entity2d.layer);

        return added;
    }

    public override function removeEntity(entity:Entity):Bool {
        var removed = super.removeEntity(entity);
        
        if(!removed || !Std.isOfType(entity, Entity2D))
            return removed;

        var entity2d = cast(entity, Entity2D);
        if(entity2d.parentOverride != null && entity2d.unparentOverrideOnRoomRemove)
            entity2d.layers.remove();
        else 
            drawTo.removeChild(entity2d.layers);

        return removed;
    }

    // & Event called when a physics update is called
    private function onPhysicsUpdate() {}
}