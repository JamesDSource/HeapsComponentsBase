package hcb.struct;

import hcb.physics.PhysicsWorld;
import hcb.comp.col.CollisionShape.Bounds;

class Room2D extends Room {
    public var scene(default, null): h2d.Scene;
    public var drawTo: h2d.Layers;
    // ^ The layers that parent the entity layers. Defaults to the scene
    
    public var collisionWorld(default, null): hcb.col.CollisionWorld;
    public var physicsWorld(default, null): hcb.physics.PhysicsWorld = null;
    public var usesPhysics: Bool;
    public var physicsPauseOnPause: Bool = true;
    private var physicsAccumulator: Float = 0;

    public function new(collisionCellSize: Float = 256) {
        super();
        scene = new h2d.Scene();
        drawTo = scene;
        collisionWorld = new hcb.col.CollisionWorld(collisionCellSize);
    }

    public function initializePhysics(bounds: Bounds, quadCapacity: Int = 4, impulseIterations: Int = 20, percentCorrection: Float = .4, slop: Float = 0.005) {
        if(usesPhysics)
            return;
        
        usesPhysics = true;
        physicsWorld = new hcb.physics.PhysicsWorld(bounds, quadCapacity);
        physicsWorld.impulseIterations = impulseIterations;
        physicsWorld.percentCorrection = percentCorrection;
        physicsWorld.slop = slop;
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

    private override function update(delta:Float) {
        super.update(delta);

        // Physics loop
        if(!usesPhysics) 
            return;

        var physicsFps: Float = physicsWorld.overrideTargetPhysicsFramerate == null
                                ? PhysicsWorld.targetPhysicsFramerate
                                : physicsWorld.overrideTargetPhysicsFramerate;

        physicsAccumulator += delta;
        while(physicsAccumulator >= 1/physicsFps) {
            if(!paused || !physicsPauseOnPause) {
                onPhysicsUpdate();
                physicsWorld.update(1/physicsFps);
            }
            physicsAccumulator -= 1/physicsFps;
        }
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