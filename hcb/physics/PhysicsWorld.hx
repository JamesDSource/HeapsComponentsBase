package hcb.physics;

import hcb.col.*;
import hcb.comp.Body;
import VectorMath;

using hcb.math.Vector;

class PhysicsWorld {
    public static var targetPhysicsFramerate: Float = 60;
    public var overrideTargetPhysicsFramerate: Null<Float> = null;

    public var forceRegistry: ForceRegistry;

    private var quadtree: Quadtree;
    private var bodies: Array<Body> = [];
    private var collisions: Array<Arbiter> = [];

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
        collisions = quadtree.updateArbitors();      

        // Update the forces
        forceRegistry.updateForces();

        // Pre-compiling arbitors
        for(collision in collisions)
            collision.preCompile(dt, percentCorrection, slop);

        // Resolving collisions via iterative impulse resolution
        for(i in 0...impulseIterations)
            for(collision in collisions)
                collision.applyImpulse();

        for(body in bodies)
            body.step(dt);
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
        g.endFill();

        if(drawQuadtree)
            quadtree.represent(g, quadRootColor, quadDivColor);
    }

    private function rebuildQuadtree() {
        quadtree.clear();
        for(body in bodies)
            quadtree.insert(body.shape);
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