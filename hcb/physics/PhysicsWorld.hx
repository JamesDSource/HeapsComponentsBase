package hcb.physics;

import hcb.col.*;
import hcb.col.Collisions.CollisionInfo;
import hcb.comp.Body;
import VectorMath;

using hcb.math.Vector;

class PhysicsWorld {
    public static var targetPhysicsFramerate: Float = 60;
    public var overrideTargetPhysicsFramerate: Null<Float> = null;

    public var forceRegistry: ForceRegistry;

    private var quadtree: Quadtree;
    private var bodies: Array<Body> = [];
    private var collisions: Array<CollisionInfo> = [];

    public var impulseIterations: Int = 15;
    public var percentCorrection: Float = 0.4;
    public var slop: Float = 0.01;

    public var collisionWorld: CollisionWorld;

    public function new(bounds: hcb.comp.col.CollisionShape.Bounds, quadCapacity: Int = 4) {
        quadtree = new Quadtree(bounds, quadCapacity);
        forceRegistry = new ForceRegistry();
    }

    public function update(dt: Float) { 
        // Collisions
        rebuildQuadtree();
        collisions = quadtree.getColliding();      

        // Update the forces
        forceRegistry.updateForces();

        // Resolving collisions via iterative impulse resolution
        for(i in 0...impulseIterations)
            for(collision in collisions)
                resolveCollision(collision);

        for(body in bodies)
            body.step(dt);

        for(collision in collisions)
            positionalCorrection(collision);
    }

    public function represent(  
        g: h2d.Graphics,
        shapeColor: Int = 0xFFFFFF,
        staticShapeColor: Int = 0xAAAAAA,
        contactColor: Int = 0x00FFFF, 
        drawQuadtree: Bool = false, 
        quadRootColor: Int = 0xFF0000, 
        quadDivColor: Int = 0xFFFF00
    ) {
        for(body in bodies) {
            var c: Int = body.infiniteMass ? staticShapeColor : shapeColor;
            body.shape.represent(g, c);
        }

        g.lineStyle();
        g.beginFill(contactColor);
        for(collision in collisions)
            for(point in collision.contactPoints)
                g.drawCircle(point.x, point.y, 2);
        g.endFill();

        if(drawQuadtree)
            quadtree.represent(g, quadRootColor, quadDivColor);
    }

    private function rebuildQuadtree() {
        quadtree.clear();
        for(body in bodies)
            quadtree.insert(body.shape);
    }

    private function resolveCollision(pCollision: CollisionInfo) {
        var body1 = pCollision.shape1.body;
        var body2 = pCollision.shape2.body;

        if(body1 == null || body2 == null || body1.shape == null || body2.shape == null) 
            return;

        var invMass1: Float = body1.inverseMass;
        var invMass2: Float = body2.inverseMass;
        var invInertia1: Float = body1.inverseInertia;
        var invInertia2: Float = body2.inverseInertia;
        
        if(invMass1 + invMass2 + invInertia1 + invInertia2 < hxd.Math.EPSILON) 
            return;

        var pos1: Vec2 = pCollision.shape1.getAbsPosition();
        var pos2: Vec2 = pCollision.shape2.getAbsPosition();

        // The coefficient of restitution should be the lower elasticity
        var e: Float = Math.min(body1.elasticity, body2.elasticity);
        var mu: Float = Math.sqrt(body1.staticFriction*body2.staticFriction);
        
        // Loop through every point of contact
        for(contactPoint in pCollision.contactPoints) {
            var arm1 = contactPoint - pos1;
            var arm2 = contactPoint - pos2;

            // Getting the relative velocity between the two points
            // This accounts for both linear and rotational velocity
            var relative: Vec2 =    (body2.velocity + arm2.crossRight(body2.angularVelocity)) - 
                                    (body1.velocity + arm1.crossRight(body1.angularVelocity));
            var velAlongNormal: Float = relative.dot(pCollision.normal);

            if(velAlongNormal > 0)
                continue;

            var impAug1 = arm1.cross(pCollision.normal);
            impAug1 = impAug1*invInertia1*impAug1;
            var impAug2 = arm2.cross(pCollision.normal);
            impAug2 = impAug2*invInertia2*impAug2;
            var invMassSum = invMass1 + invMass2 + impAug1 + impAug2;

            var j = (-(1 + e)*velAlongNormal)/invMassSum;
            var impulse = j*pCollision.normal/pCollision.contactPoints.length;
            body1.impulse(-impulse, arm1);
            body2.impulse( impulse, arm2);

            // Getting friction
            var relativeVelocity: Vec2 =    (body2.velocity + arm2.crossRight(body2.angularVelocity)) -
                                            (body1.velocity + arm1.crossRight(body1.angularVelocity));
            var tangent: Vec2 = normalize(relativeVelocity - pCollision.normal*relativeVelocity.dot(pCollision.normal));

            // Calculate the friction magnitude
            var jt: Float = -relativeVelocity.dot(tangent)/invMassSum;
            jt /= pCollision.contactPoints.length;

            if(jt < hxd.Math.EPSILON)
                continue;
            
            var frictionImpulse: Vec2;
            if(Math.abs(jt) < j*mu)
                frictionImpulse = jt*tangent;
            else {
                var dynamicFriction = Math.sqrt(body1.dynamicFriction*body2.dynamicFriction);
                frictionImpulse = -j*tangent*dynamicFriction;
            }

            body1.impulse(-frictionImpulse, arm1);
            body2.impulse( frictionImpulse, arm2);
        }
    }

    private function positionalCorrection(pCollision: CollisionInfo) {
        var body1 = pCollision.shape1.body;
        var body2 = pCollision.shape2.body;

        if(body1 == null || body2 == null) 
            return;

        var invMass1 = body1.inverseMass;
        var invMass2 = body2.inverseMass;
        var invMassSum = invMass1 + invMass2;

        if(invMassSum == 0) 
            return;

        var correction: Vec2 = (Math.max(pCollision.depth - slop, 0)/invMassSum)*percentCorrection*pCollision.normal;

        if(body1.parent2d != null)
            body1.parent2d.transform.translate(-invMass1*correction);

        if(body2.parent2d != null)
            body2.parent2d.transform.translate(invMass2*correction);
    }

    public function addBody(body: Body) {
        if(!bodies.contains(body)) {
            bodies.push(body);
            quadtree.insert(body.shape);
        }
    }

    public function removeBody(body: Body): Bool {
        var r = bodies.remove(body);
        if(r)
            rebuildQuadtree();
        return r;
    }

    public function contains(body: Body) {
        return bodies.contains(body);
    }

    public function getBodies(): Array<Body> {
        return bodies.copy();
    }

    public function clear() {
        for(body in bodies.copy())
            removeBody(body);

        rebuildQuadtree();
    }
}