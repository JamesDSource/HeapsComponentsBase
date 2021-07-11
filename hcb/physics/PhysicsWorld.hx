package hcb.physics;

import hcb.col.*;
import hcb.col.Collisions.CollisionInfo;
import hcb.comp.Body;
import VectorMath;

using hcb.math.Vector;

class PhysicsWorld {
    private var collisionWorld: CollisionWorld;
    public var forceRegistry: ForceRegistry;

    private var bodies: Array<Body> = [];
    private var collisions: Array<CollisionInfo> = [];

    public var impulseIterations: Int = 10;
    public var percentCorrection: Float = 0.3;
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
            if(body.shape != null)
                collisionWorld.getCollisionAt(body.shape, collisions, true);
        }

        // * Update the forces
        forceRegistry.updateForces();


        // * Resolving collisions via iterative impulse resolution
        for(i in 0...impulseIterations) {
            for(collision in collisions) {
                resolveCollision(collision);
            }
        }

        for(body in bodies)
            body.physicsUpdate();

        for(collision in collisions)
            positionalCorrection(collision);
    }

    private function resolveCollision(pCollision: CollisionInfo) {
        var body1 = pCollision.shape1.body;
        var body2 = pCollision.shape2.body;

        if(body1 == null || body2 == null || body1.shape == null || body2.shape == null) return;

        var invMass1: Float = body1.inverseMass;
        var invMass2: Float = body2.inverseMass;
        var invAngularInertia1: Float = body1.inverseAngularInertia;
        var invAngularInertia2: Float = body2.inverseAngularInertia;
        
        if(invMass1 + invMass2 + invAngularInertia1 + invAngularInertia2 < hxd.Math.EPSILON) return;

        var pos1: Vec2 = pCollision.shape1.getAbsPosition();
        var pos2: Vec2 = pCollision.shape2.getAbsPosition();

        // * The coefficient of restitution should be the lower elasticity
        var e: Float = Math.min(body1.elasticity, body2.elasticity);

        var mu: Float = length(vec2(body1.staticFriction, body2.staticFriction));

        for(point in pCollision.contactPoints) {
            // * Get the arms
            var ra: Vec2 = point - pos1;
            var rb: Vec2 = point - pos2;
            
            // * Get the relative velocity and compare it to the normal
            var relativeVelocity: Vec2 =    body2.velocity + rb.crossRight(body2.angularVelocity) - 
                                            body1.velocity - ra.crossRight(body1.angularVelocity);
            var velocityAlongNormal: Float = relativeVelocity.dot(pCollision.normal);

            // * Do not resolve if velocities are seperating
            if(velocityAlongNormal > 0)
                return;


            var raCN = ra.cross(pCollision.normal);
            var rbCN = rb.cross(pCollision.normal);
            var invMassSum = invMass1 + invMass2 + raCN*raCN*invAngularInertia1 + rbCN*rbCN*invAngularInertia2;

            // * Calculate the impulse scaler
            var j: Float = -(1 + e)*velocityAlongNormal;
            j /= invMassSum;
            j /= pCollision.contactPoints.length;

            var impulse: Vec2 = j*pCollision.normal;
            body1.impulse(-impulse, ra);
            body2.impulse(impulse, rb);

            // * Getting friction
            var relativeVelocity: Vec2 =    (body2.velocity + rb.crossRight(body2.angularVelocity)) - 
                                            (body1.velocity - ra.crossRight(body1.angularVelocity));
            var tangent: Vec2 = normalize(relativeVelocity - relativeVelocity.dot(pCollision.normal)*pCollision.normal);

            // * Calculate the friction magnitude
            var jt: Float = -relativeVelocity.dot(tangent)/invMassSum;
            jt /= pCollision.contactPoints.length;

            if(jt < hxd.Math.EPSILON)
                continue;
            
            var frictionImpulse: Vec2;
            if(Math.abs(jt) < j*mu)
                frictionImpulse = jt*tangent;
            else {
                var dynamicFriction = length(vec2(body1.dynamicFriction, body2.dynamicFriction));
                frictionImpulse = -j*tangent*dynamicFriction;
            }

            body1.impulse(-frictionImpulse, ra);
            body2.impulse(frictionImpulse, rb);
        }
    }

    private function positionalCorrection(pCollision: CollisionInfo) {
        var body1 = pCollision.shape1.body;
        var body2 = pCollision.shape2.body;

        if(body1 == null || body2 == null) return;

        var invMass1 = body1.inverseMass;
        var invMass2 = body2.inverseMass;

        if(invMass1 + invMass2 == 0) return;

        var correction: Vec2 = (Math.max(pCollision.depth - slop, 0)/(invMass1 + invMass2))*percentCorrection*pCollision.normal;
        
        if(body1.parent2d != null)
            body1.parent2d.transform.translate(-invMass1*correction);

        if(body2.parent2d != null)
            body2.parent2d.transform.translate(invMass2*correction);
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