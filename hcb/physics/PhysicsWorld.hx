package hcb.physics;

import hcb.comp.col.Collisions;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.Body;
import VectorMath;

typedef PhysicsCollision = {
    body1: Body,
    body2: Body,
    collision: CollisionInfo
}

class PhysicsWorld {
    private var collisionWorld: CollisionWorld;
    private var forceRegistry: ForceRegistry;

    private var bodies: Array<Body> = [];
    private var collisions: Array<PhysicsCollision> = [];

    public var impulseIterations: Int = 8;

    public var graphics: h2d.Graphics = new h2d.Graphics();

    public function new(collisionWorld: CollisionWorld) {
        this.collisionWorld = collisionWorld;
        forceRegistry = new ForceRegistry();
    }

    public function update(delta: Float) { 

        // * Collisions
        collisions = [];
        for(body1 in bodies) {
            for(body2 in bodies) {
                if(body1 == body2) continue;

                // * Both cannot have infinite mass, and both must have a shape
                if(body1.shape != null && body2.shape != null && (!body1.infiniteMass || !body2.infiniteMass)) {
                    var result: CollisionInfo = Collisions.polyWithPoly(cast body1.shape , cast body2.shape);
                    
                    if(result.isColliding) {
                        graphics.beginFill(0x0000ff);
                        for(point in result.contactPoints) {
                            //graphics.drawCircle(point.x, point.y, 1);
                        }
                        graphics.endFill();
                        collisions.push({body1: body1, body2: body2, collision: result});
                    }
                }
            }
        }

        // * Update the forces
        forceRegistry.updateForces(delta);

        // * Resolving collisions via iterative impulse resolution
        for(i in 0...impulseIterations) {
            for(collision in collisions) {
                for(contactPoint in collision.collision.contactPoints) {
                    applyImpulse(collision);
                }
            }
        }


        for(body in bodies) {
            body.physicsUpdate(delta);
        }
    }

    private function applyImpulse(pCollision: PhysicsCollision) {
        var invMass1: Float = pCollision.body1.inverseMass,
            invMass2: Float = pCollision.body2.inverseMass,
            invMassSum: Float = invMass1 + invMass2;
        
        if(invMassSum == 0) return;

        var relativeVelocity: Vec2 = pCollision.body2.velocity - pCollision.body1.velocity;
        var normal: Vec2 = pCollision.collision.normal;

        // * Do nothing if they are moving away from each other
        if(relativeVelocity.dot(normal) > 0) {
            return;
        }

        var e: Float = Math.min(pCollision.body1.elasticity, pCollision.body2.elasticity);
        var numerator = -(1.0 + e)*relativeVelocity.dot(normal);
        var force = numerator/invMassSum;

        // * Divide by the number of contact points to distribute it equally
        if(pCollision.collision.contactPoints.length > 0) {
            force /= pCollision.collision.contactPoints.length;
        }

        var impulse = normal*force;
        pCollision.body1.velocity -= impulse*invMass1;
        pCollision.body2.velocity += impulse*invMass2;
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