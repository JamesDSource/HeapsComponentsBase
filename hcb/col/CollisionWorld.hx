package hcb.col;

import hcb.col.Collisions.Raycast;
import hcb.col.Collisions.CollisionInfo;
import hcb.comp.col.CollisionShape.Bounds;
import hcb.comp.col.*;
import VectorMath;
import hcb.SignedArray;

typedef RayResult = {
    intersectionPoint: Vec2,
    shape: CollisionShape
}

class CollisionWorld {
    private var shapes: Array<CollisionShape> = [];

    private var collisionCellSize: Float = 128;
    public var collisionCells = new SignedArray<SignedArray<Array<CollisionShape>>>();

    public function new(collisionCellSize: Float = 256) {
        this.collisionCellSize = collisionCellSize;
    }

    public function addShape(shape: CollisionShape) {
        shapes.push(shape);
        shape.collisionWorld = this;
        shape.updateCollisionCells();
    }

    public function removeShape(shape: CollisionShape) {
        shapes.remove(shape);
        shape.collisionWorld = null;
        shape.updateCollisionCells();
    }

    public function clear() {
        for(shape in getShapes()) {
            removeShape(shape);
        }
    }

    public function getShapes(): Array<CollisionShape> {
        return shapes.copy();
    }

    public function getShapesFromBounds(bounds: Bounds): Array<CollisionShape> {
        var shapes: Array<CollisionShape> = [];

        var x0: Int = Math.floor(bounds.min.x/collisionCellSize),
            y0: Int = Math.floor(bounds.min.y/collisionCellSize),
            x1: Int = Math.floor(bounds.max.x/collisionCellSize),
            y1: Int = Math.floor(bounds.max.y/collisionCellSize);
        
        for(i in x0...(x1 + 1)) {
            if(collisionCells.get(i) != null) {
                for(j in y0...(y1 + 1)) {
                    var cellShapes: Array<CollisionShape> = collisionCells.get(i).get(j);
                    
                    if(cellShapes != null) {
                        for(shape in cellShapes) {
                            if(!shapes.contains(shape)) {
                                shapes.push(shape);
                            }
                        }
                    }

                }
            }
        }

        return shapes;
    }

    public function setShapeFromBounds(bounds: Bounds, shape: CollisionShape): Array<Array<CollisionShape>> {
        var shapeLists: Array<Array<CollisionShape>> = [];
        
        var x0: Int = Math.floor(bounds.min.x/collisionCellSize),
            y0: Int = Math.floor(bounds.min.y/collisionCellSize),
            x1: Int = Math.floor(bounds.max.x/collisionCellSize),
            y1: Int = Math.floor(bounds.max.y/collisionCellSize);

        for(i in x0...(x1 + 1)) {
            if(collisionCells.get(i) == null) {
                collisionCells.set(i, new SignedArray<Array<CollisionShape>>());
            }

            for(j in y0...(y1 + 1)) {
                if(collisionCells.get(i).get(j) == null) {
                    collisionCells.get(i).set(j, new Array<CollisionShape>());
                }

                collisionCells.get(i).get(j).push(shape);
                shapeLists.push(collisionCells.get(i).get(j));
            }
        }

        return shapeLists;
    }

    // & Returns the largest depth collision for one shape
    public extern overload inline function getCollisionAt(collisionShape: CollisionShape, ?position: Vec2, ?tag: String): CollisionInfo {
        var result: CollisionInfo = null;
        
        var prevOverride: Vec2 = collisionShape.overridePosition;
        if(position != null) 
            collisionShape.overridePosition = position;
        
        var cellShapes = getShapesFromBounds(collisionShape.bounds);
        var largestDepth: Float = Math.NEGATIVE_INFINITY;
        for(shape in cellShapes) {
            if(tag != null && !shape.tags.contains(tag))
                continue;

            if(collisionShape != shape) {
                var colResult = Collisions.test(collisionShape, shape);
                if(colResult.isColliding && colResult.depth > largestDepth) {
                    result = colResult;
                    largestDepth = colResult.depth;
                }
            }
        }
        
        collisionShape.overridePosition = prevOverride;

        return result;
    }

    // & Returns the largest depth collision for multiple shapes
    public extern overload inline function getCollisionAt(collisionShapes: Array<CollisionShape>, ?position: Vec2, ?tag: String): CollisionInfo {
        var result: CollisionInfo = null;
        
        for(collisionShape in collisionShapes) {
            var prevOverride: Vec2 = collisionShape.overridePosition;
            if(position != null) 
                collisionShape.overridePosition = position;

            var cellShapes = getShapesFromBounds(collisionShape.bounds);
            var largestDepth: Float = Math.NEGATIVE_INFINITY;
            for(shape in cellShapes) {
                if(tag != null && !shape.tags.contains(tag))
                    continue;

                if(!collisionShapes.contains(shape)) {
                    var colResult = Collisions.test(collisionShape, shape);
                    if(colResult.isColliding && colResult.depth > largestDepth) {
                        result = colResult;
                        largestDepth = colResult.depth;
                    }
                }
            }
            
            collisionShape.overridePosition = prevOverride;
        }
        
        return result;
    }

    // & Returns all collisions for one shape
    public extern overload inline function getCollisionAt(collisionShape: CollisionShape, output: Array<CollisionInfo>, ?position: Vec2, ?tag: String): Int {
        var count: Int = 0;
        
        var prevOverride: Vec2 = collisionShape.overridePosition;
        if(position != null) 
            collisionShape.overridePosition = position;
        
        var cellShapes = getShapesFromBounds(collisionShape.bounds);
        for(shape in cellShapes) {
            if(tag != null && !shape.tags.contains(tag))
                continue;

            if(collisionShape != shape) {
                var result = Collisions.test(collisionShape, shape);
                if(result.isColliding) {
                    output.push(result);
                    count++;
                }
            }
        }
        
        collisionShape.overridePosition = prevOverride;

        return count;
    }

    // & Returns all collisions for multiple shapes
    public extern overload inline function getCollisionAt(collisionShapes: Array<CollisionShape>, output: Array<CollisionInfo>, ?position: Vec2, ?tag: String): Int {
        var count: Int = 0;
        
        for(collisionShape in collisionShapes) {
            var prevOverride: Vec2 = collisionShape.overridePosition;
            if(position != null) 
                collisionShape.overridePosition = position;

            var cellShapes = getShapesFromBounds(collisionShape.bounds);
            for(shape in cellShapes) {
                if(tag != null && !shape.tags.contains(tag))
                    continue;

                if(!collisionShapes.contains(shape)) {
                    var result = Collisions.test(collisionShape, shape);
                    if(result.isColliding) {
                        output.push(result);
                        count++;
                    }
                }
            }
            
            collisionShape.overridePosition = prevOverride;
        }
        return count;
    }

    // & Returns a raycast result closest to the ray origin
    public extern overload inline function getCollisionAt(rayCast: Raycast, ?tag: String): RayResult {
        var result: RayResult = null;
        
        // * Check every shape if the raycast is infinite
        var cellShapes: Array<CollisionShape>;
        if(rayCast.infinite) {
            cellShapes = shapes.copy();
        }
        else {
            var bounds = {
                min: vec2(0, 0),
                max: vec2(0, 0)
            };
            bounds.min.x = Math.min(rayCast.origin.x, rayCast.origin.x + rayCast.castTo.x);
            bounds.min.y = Math.min(rayCast.origin.y, rayCast.origin.y + rayCast.castTo.y);
            bounds.max.x = Math.max(rayCast.origin.x, rayCast.origin.x + rayCast.castTo.x);
            bounds.max.y = Math.max(rayCast.origin.y, rayCast.origin.y + rayCast.castTo.y);

            cellShapes = getShapesFromBounds(bounds);
        }
        
        for(shape in cellShapes) {
            if(tag != null && !shape.tags.contains(tag))
                continue;

            var rayResult: Vec2 = Collisions.raycastTest(rayCast, shape);
            if(rayResult != null && (result == null || rayResult.distance(rayCast.origin) < result.intersectionPoint.distance(rayCast.origin))) {
                result = {
                    intersectionPoint: rayResult,
                    shape: shape
                }
            }
        }
        
        return result;
    }

    // & Returns all raycast results
    public extern overload inline function getCollisionAt(rayCast: Raycast, output: Array<RayResult>, ?tag:String): Int {
        var count: Int = 0;
        
        // * Check every shape if the raycast is infinite
        var cellShapes: Array<CollisionShape>;
        if(rayCast.infinite) {
            cellShapes = shapes.copy();
        }
        else {
            var bounds = {
                min: vec2(0, 0),
                max: vec2(0, 0)
            };
            bounds.min.x = Math.min(rayCast.origin.x, rayCast.origin.x + rayCast.castTo.x);
            bounds.min.y = Math.min(rayCast.origin.y, rayCast.origin.y + rayCast.castTo.y);
            bounds.max.x = Math.max(rayCast.origin.x, rayCast.origin.x + rayCast.castTo.x);
            bounds.max.y = Math.max(rayCast.origin.y, rayCast.origin.y + rayCast.castTo.y);

            cellShapes = getShapesFromBounds(bounds);
        }
        
        for(shape in cellShapes) {
            if(tag != null && !shape.tags.contains(tag))
                continue;

            var rayResult: Vec2 = Collisions.raycastTest(rayCast, shape);
            if(rayResult != null) {
                output.push({intersectionPoint: rayResult, shape: shape});
                count++;
            }
        }
        
        return count;
    }

    // & Returns first collision at a certain point
    public extern overload inline function getCollisionAt(point: Vec2, ?tag: String): CollisionShape {
        var result: CollisionShape = null;

        var cellShapes = getShapesFromBounds({min: point, max: point});
        for(shape in cellShapes) {
            if((tag == null || shape.tags.contains(tag)) && Collisions.pointTest(point, shape)) {
                result = shape;
                break;
            }
        }

        return result;
    }

    // & Returns all collisions at a certain point
    public extern overload inline function getCollisionAt(point: Vec2, output: Array<CollisionShape>, ?tag: String): Int {
        var count: Int = 0;
        
        var cellShapes = getShapesFromBounds({min: point, max: point});
        for(shape in cellShapes) {
            if((tag == null || shape.tags.contains(tag)) && Collisions.pointTest(point, shape)) {
                output.push(shape);
                count++;
            }
        }
        
        return count;
    }

    public function representShapes(g: h2d.Graphics, showBounds: Bool = false, boundsColor: Int = 0xFFFFFF) {
        for(shape in shapes) {

            shape.represent(g);

            if(showBounds) {
                g.lineStyle(1, boundsColor);
                var bbox = shape.bounds;
                g.drawRect(bbox.min.x, bbox.min.y, bbox.max.x - bbox.min.x, bbox.max.y - bbox.min.y);
            }
        }

    }
}