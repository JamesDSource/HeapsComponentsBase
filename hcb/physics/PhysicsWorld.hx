package hcb.physics;

import haxe.ds.ReadOnlyArray;
import hcb.comp.col.Collisions;
import hcb.comp.col.Collisions.CollisionInfo;
import hcb.comp.Body;
import VectorMath;

class PhysicsWorld {
    private var collisionWorld: CollisionWorld;
    private var forceRegistry: ForceRegistry;

    private var bodies: Array<Body> = [];
    private var collisions: Array<CollisionInfo> = [];

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
                            graphics.drawCircle(point.x, point.y, 1);
                        }
                        graphics.endFill();
                        collisions.push(result);
                    }
                }
            }
        }

        // * Update the forces
        forceRegistry.updateForces(delta);

        // * Resolving collisions via iterative impulse resolution
        for(i in 0...impulseIterations) {
            for(collision in collisions) {
                applyImpulse(collision);
            }
        }


        for(body in bodies) {
            body.physicsUpdate(delta);
        }
    }

    private function applyImpulse(pCollision: CollisionInfo) {
        var body1 = pCollision.shape1.body;
        var body2 = pCollision.shape2.body;

        if(body1 == null || body2 == null) return;
        
        var invMass1: Float = body1.inverseMass,
            invMass2: Float = body2.inverseMass,
            invMassSum: Float = invMass1 + invMass2;
        
        if(invMassSum == 0) return;

        var relativeVelocity: Vec2 = body2.velocity - body1.velocity;
        var normal: Vec2 = pCollision.normal;

        // * Do nothing if they are moving away from each other
        if(relativeVelocity.dot(normal) > 0) return;

        var e: Float = Math.min(body1.elasticity, body2.elasticity);
        var numerator = -(1.0 + e)*relativeVelocity.dot(normal);
        var force = numerator/invMassSum;
        var impulse = normal*force;

        var massSum = body1.mass = body2.mass;
        var ratio = body1.mass/massSum;
        body1.velocity -= impulse*ratio*invMass1;
        
        ratio = body2.mass/massSum;
        body2.velocity += impulse*ratio*invMass2;

        // * Friction
        relativeVelocity = body2.velocity - body1.velocity;
        var t: Vec2 = vec2(-normal.y, normal.x);
        var tangent: Vec2 = (relativeVelocity - relativeVelocity.dot(normal)*normal).normalize();
        var jt: Float = (-relativeVelocity.dot(t))/invMassSum;
        var mu: Float = vec2(body1.staticFriction, body2.staticFriction).length();

        var fricImpulse: Vec2;
        if(Math.abs(jt) < force*mu) {
            fricImpulse = t*jt;
        }
        else {
            var dynamicFriction = vec2(body1.dynamicFriction, body2.dynamicFriction).length();
            fricImpulse = -force*t*dynamicFriction;
        }

        body1.velocity -= fricImpulse*invMass1;
        body2.velocity += fricImpulse*invMass2;
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