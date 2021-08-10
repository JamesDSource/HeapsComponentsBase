package hcb.physics;

import hcb.col.*;
import hcb.comp.col.CollisionShape;
import VectorMath;

class Quadtree {
    private var bounds: Bounds;

    private var globalShapes: Array<CollisionShape> = [];
    private var shapes: Array<CollisionShape> = [];
    public var capacity: Int;

    private var nw: Quadtree = null;
    private var ne: Quadtree = null;
    private var sw: Quadtree = null;
    private var se: Quadtree = null;
    private var divided: Bool = false;

    public function new(bounds: Bounds, capacity: Int = 4, ?globalShapes: Array<CollisionShape>) {
        this.bounds = {min: bounds.min.clone(), max: bounds.max.clone()};
        this.capacity = capacity;

        if(globalShapes != null)
            this.globalShapes = globalShapes;
    }

    public function insert(shape: CollisionShape) {
        // Only add if there is a bounds intersection
        if(!Collisions.boundsIntersection(bounds, shape.bounds))
            return;

        if(!globalShapes.contains(shape))
            globalShapes.push(shape);
        
        if(this.shapes.length < capacity)
            shapes.push(shape);
        else {
            if(!divided)
                subDivide();

            nw.insert(shape);
            ne.insert(shape);
            sw.insert(shape);
            se.insert(shape);
        }
    }

    public function updateArbiters(arbiters: Array<Arbiter>): Array<Arbiter> {
        var result: Array<Arbiter> = [];
        var checked: Map<CollisionShape, Array<CollisionShape>> = [];
        
        for(shape in globalShapes) {
            var testShapes: Array<CollisionShape> = [];
            query(shape.bounds, testShapes);
            if(testShapes.length == 0)
                continue;

            checked[shape] = [];

            for(testShape in testShapes) {
                if ( 
                    shape == testShape || 
                    shape.body.mass + testShape.body.mass < hxd.Math.EPSILON || 
                    (
                        checked.exists(testShape) && 
                        checked[testShape].contains(shape)
                    )
                ) continue;

                checked[shape].push(testShape);

                var m = new Manifold();
                if(!Collisions.test(shape, testShape, m))
                    continue;
                
                // Update the Arbiter if it exists from the previous frame
                var found: Bool = false;
                for(arb in arbiters) {
                    if( 
                        (arb.b1 == shape.body && arb.b2 == testShape.body) || 
                        (arb.b1 == testShape.body && arb.b2 == shape.body)
                    ) {
                        found = true;
                        arb.update(m.convertToContacts());
                        result.push(arb);
                        break;
                    }
                }
                if(!found)
                    result.push(new Arbiter(shape.body, testShape.body, m.convertToContacts()));
            }
        }
        return result;
    }

    public function query(inBounds: Bounds, queryTo: Array<CollisionShape>, precise: Bool = false) {
        if(!Collisions.boundsIntersection(inBounds, bounds))
            return;
        
        for(shape in shapes) {
            if(!queryTo.contains(shape) && (!precise || Collisions.boundsIntersection(inBounds, shape.bounds)))
                queryTo.push(shape);
        }

        if(divided) {
            nw.query(inBounds, queryTo);
            ne.query(inBounds, queryTo);
            sw.query(inBounds, queryTo);
            se.query(inBounds, queryTo);
        }
    }

    public function clear() {
        globalShapes = [];
        shapes = [];
        nw = ne = sw = se = null;
        divided = false;
    }

    public function represent(g: h2d.Graphics, rootColor: Int = 0xFF0000, divisionColor: Int = 0xFFFFFF, drawRoot: Bool = true) {
        var w = bounds.max.x - bounds.min.x;
        var h = bounds.max.y - bounds.min.y;
        
        if(drawRoot) {
            g.lineStyle(1, rootColor);
            g.drawRect(bounds.min.x, bounds.min.y, w, h);
        }

        if(divided) {
            g.lineStyle(1, divisionColor);
            g.moveTo(bounds.min.x + w/2, bounds.min.y);
            g.lineTo(bounds.min.x + w/2, bounds.max.y);
            g.moveTo(bounds.min.x, bounds.min.y + h/2);
            g.lineTo(bounds.max.x, bounds.min.y + h/2);

            nw.represent(g, rootColor, divisionColor, false);
            ne.represent(g, rootColor, divisionColor, false);
            sw.represent(g, rootColor, divisionColor, false);
            se.represent(g, rootColor, divisionColor, false);
        }
    }

    // Function that divides the bounds in a quad
    private function subDivide() {
        if(divided)
            return;

        var nwBounds: Bounds = {
            min: bounds.min.clone(),
            max: bounds.min + (bounds.max - bounds.min)/2
        }
        var neBounds: Bounds = {
            min: vec2(bounds.min.x + (bounds.max.x - bounds.min.x)/2, bounds.min.y),
            max: vec2(bounds.max.x, bounds.min.y + (bounds.max.y - bounds.min.y)/2)
        }
        var swBounds: Bounds = {
            min: vec2(bounds.min.x, bounds.min.y + (bounds.max.y - bounds.min.y)/2),
            max: vec2(bounds.min.x + (bounds.max.x - bounds.min.x)/2, bounds.max.y)
        }
        var seBounds: Bounds = {
            min: bounds.min + (bounds.max - bounds.min)/2,
            max: bounds.max.clone()
        }


        nw = new Quadtree(nwBounds, capacity, globalShapes);
        ne = new Quadtree(neBounds, capacity, globalShapes);
        sw = new Quadtree(swBounds, capacity, globalShapes);
        se = new Quadtree(seBounds, capacity, globalShapes);

        divided = true;
    }
}