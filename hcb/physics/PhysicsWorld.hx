package hcb.physics;

import hcb.math.Vector;
import haxe.ds.ReadOnlyArray;
import hcb.comp.col.Collisions;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.Body;
import VectorMath;

class PhysicsWorld {
    private var collisionWorld: CollisionWorld;
    public var forceRegistry: ForceRegistry;

    private var bodies: Array<Body> = [];
    private var collisions: Array<CollisionInfo> = [];

    public var impulseIterations: Int = 12;
    public var percentCorrection: Float = 0.4;
    public var slop: Float = 0.01;

    public function new(collisionWorld: CollisionWorld) {
        this.collisionWorld = collisionWorld;
        forceRegistry = new ForceRegistry();
    }

    public function update() { 

        // * Collisions
        collisions = [];
        for(body in bodies) {
            // * Both cannot have infinite mass, and both must have a shape
            if(body.shape != null) {
                var results: Array<CollisionInfo> = [];
                collisionWorld.getCollisionAt(body.shape, results);
                for(result in results) {
                    if(result.isColliding && result.shape1.body != null && result.shape2.body != null) {
                        collisions.push(result);
                    }
                }
            }
        }

        // * Update the forces
        forceRegistry.updateForces();


        // * Resolving collisions via iterative impulse resolution
        for(i in 0...impulseIterations) {
            for(collision in collisions) {
                resolveCollision(collision);
            }
        }

        for(body in bodies) {
            body.physicsUpdate();
        }

        for(collision in collisions) {
            positionalCorrection(collision);
        }

    }

    private function resolveCollision(pCollision: CollisionInfo) {
        var body1 = pCollision.shape1.body;
        var body2 = pCollision.shape2.body;

        if(body1 == null || body2 == null || body1.shape == null || body2.shape == null) return;
        
        var invMass1: Float = body1.inverseMass,
            invMass2: Float = body2.inverseMass,
            invAngularInertia1: Float = body1.inverseAngularInertia,
            invAngularInertia2: Float = body2.inverseAngularInertia;
        
        if(invMass1 + invMass2 + invAngularInertia1 + invAngularInertia2 == 0) return;

        var relativeVelocity: Vec2 = body2.velocity - body1.velocity;
        var velocityAlongNormal: Float = relativeVelocity.dot(pCollision.normal);        

        if(velocityAlongNormal > 0) return;

        var e: Float = Math.min(body1.elasticity, body2.elasticity);

        for(point in pCollision.contactPoints) {
            var arm1 = point - body1.shape.getAbsPosition();
            var arm2 = point - body2.shape.getAbsPosition();

            var j = -(1 + e)*velocityAlongNormal;
            j /= invMass1 + invMass2 + Math.pow(Vector.cross(arm1, pCollision.normal), 2)*invAngularInertia1 + Math.pow(Vector.cross(arm2, pCollision.normal), 2)*invAngularInertia2;
            
            var impulseForce: Vec2 = j*pCollision.normal;
            body1.impulse(-impulseForce/pCollision.contactPoints.length, arm1);
            body2.impulse(impulseForce/pCollision.contactPoints.length, arm2);
        
            // * Friction
            // * Recalculate relative velocity because it has changed
            relativeVelocity = body2.velocity - body1.velocity;

            var tangent: Vec2 = (relativeVelocity - relativeVelocity.dot(pCollision.normal)*pCollision.normal).normalize();
            var jt = -dot(relativeVelocity, tangent);
            jt /= invMass1 + invMass2;

            var mu: Float = vec2(body1.staticFriction, body2.staticFriction).length();
            var frictionImpulse: Vec2;
            if(Math.abs(jt) < j*mu) {
                frictionImpulse = jt*tangent;
            }
            else {
                var dynamicFriction: Float = vec2(body1.dynamicFriction, body2.dynamicFriction).length();
                frictionImpulse = -j*tangent*dynamicFriction;
            }

            body1.impulse(-frictionImpulse);
            body2.impulse(frictionImpulse);
        }
    }

    private function positionalCorrection(pCollision: CollisionInfo) {
        var body1 = pCollision.shape1.body;
        var body2 = pCollision.shape2.body;

        if(body1 == null || body2 == null) return;

        var invMass1 = body1.inverseMass;
        var invMass2 = body2.inverseMass;

        if(invMass1 + invMass2 == 0) return;

        var correction: Vec2 = Math.max(pCollision.depth - slop, 0)/(invMass1 + invMass2)*percentCorrection*pCollision.normal;
        
        if(body1.parentEntity != null) {
            body1.parentEntity.move(-invMass1*correction);
        }

        if(body2.parentEntity != null) {
            body2.parentEntity.move(invMass2*correction);
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

    public function getBodies(): Array<Body> {
        return bodies.copy();
    }

    public function clear() {
        for(body in bodies.copy()) {
            removeBody(body);
        }
    }
}