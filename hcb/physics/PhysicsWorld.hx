package hcb.physics;

import hcb.comp.Body;

class PhysicsWorld {
    private var collisionWorld: CollisionWorld;
    private var forceRegistry: ForceRegistry;

    private var bodies: Array<Body> = [];

    public function new(collisionWorld: CollisionWorld) {
        this.collisionWorld = collisionWorld;
        forceRegistry = new ForceRegistry();
    }

    public function update(delta: Float) {
        forceRegistry.updateForces(delta);

        for(body in bodies) {
            body.physicsUpdate(delta);
        }
    }

    public function addBody(body: Body) {
        if(!bodies.contains(body)) {
            bodies.push(body);
        }
    }

    public function removeBody(body: Body): Bool {
        return bodies.remove(body);
    }

    public function contains(body: Body) {
        return bodies.contains(body);
    }
}