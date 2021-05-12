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

    public var graphics: h2d.Graphics = new h2d.Graphics();

    public function new(collisionWorld: CollisionWorld) {
        this.collisionWorld = collisionWorld;
        forceRegistry = new ForceRegistry();
    }

    public function update() { 

        // * Collisions
        collisions = [];
        for(body1 in bodies) {
            for(body2 in bodies) {
                if(body1 == body2) continue;

                // * Both cannot have infinite mass, and both must have a shape
                if(body1.shape != null && body2.shape != null && (!body1.infiniteMass || !body2.infiniteMass)) {
                    var result: CollisionInfo = Collisions.test(body1.shape , body2.shape);
                    
                    if(result.isColliding) {
                        graphics.beginFill(0x0000FF);
                        for(point in result.contactPoints) {
                            graphics.drawCircle(point.x, point.y, 1);
                        }
                        graphics.endFill();
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

        for(point in pCollision.contactPoints) {
            // * Getting the arms
            var arm1 = point - body1.shape.center;
            var arm2 = point - body2.shape.center;

            var relativeVelocity: Vec2 = body2.velocity + Vector.cross(body2.angularVelocity, arm2) - body1.velocity - Vector.cross(body1.angularVelocity, arm1);
            var normal: Vec2 = pCollision.normal;

            // * Do nothing if they are moving away from each other
            if(relativeVelocity.dot(normal) > 0) return;

            var armCrossN1: Float = Vector.cross(arm1, normal);
            var armCrossN2: Float = Vector.cross(arm2, normal);
            var invMassSum = invMass1 + invMass2 + (armCrossN1*armCrossN1)*invAngularInertia1 + (armCrossN2*armCrossN2)*invAngularInertia2;

            // * Getting impuse scaler
            var e: Float = Math.min(body1.elasticity, body2.elasticity);
            var numerator = -(1.0 + e)*relativeVelocity.dot(normal);
            var force = numerator/invMassSum;
            force /= pCollision.contactPoints.length;
            var impulse = normal*force;

            body1.impulse(-impulse, arm1);
            body2.impulse(impulse, arm2);

            // * Friction
            var relativeVelocity: Vec2 = body2.velocity + Vector.cross(body2.angularVelocity, arm2) - body1.velocity - Vector.cross(body1.angularVelocity, arm1);
            var t: Vec2 = relativeVelocity - (normal*relativeVelocity.dot(normal)).normalize();
            var jt: Float = -(relativeVelocity.dot(t))/invMassSum;
            jt /= pCollision.contactPoints.length;
            
            if(jt < 0.0001) return;

            var mu: Float = vec2(body1.staticFriction, body2.staticFriction).length();
            var fricImpulse: Vec2;
            if(Math.abs(jt) < force*mu) {
                fricImpulse = t*jt;
            }
            else {
                var dynamicFriction = vec2(body1.dynamicFriction, body2.dynamicFriction).length();
                fricImpulse = -force*t*dynamicFriction;
            }

            body1.impulse(-fricImpulse*invMass1, arm1);
            body2.impulse(fricImpulse*invMass2, arm2);
        }

    }

    private function positionalCorrection(pCollision: CollisionInfo) {
        var body1 = pCollision.shape1.body;
        var body2 = pCollision.shape2.body;

        var invMass1 = body1.inverseMass;
        var invMass2 = body2.inverseMass;

        if(invMass1 + invMass2 == 0) return;

        var percent: Float = 0.4;
        var slop: Float = 0.1;
        var correction: Vec2 = Math.max(pCollision.depth - slop, 0)/(invMass1 + invMass2)*percent*pCollision.normal;
        
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