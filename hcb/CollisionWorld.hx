package hcb;
import hcb.comp.col.Collisions.Raycast;
import hcb.comp.col.Collisions.CollisionInfo;
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
    private var shapeRender = new h2d.Graphics();

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

    // & Returns the first collision for one shape
    public extern overload inline function getCollisionAt(collisionShape: CollisionShape, ?position: Vec2): CollisionInfo {
        var result: CollisionInfo = null;
        
        var prevOverride: Vec2 = collisionShape.overridePosition;
        if(position != null) 
            collisionShape.overridePosition = position;
        
        var cellShapes = getShapesFromBounds(collisionShape.bounds);
        for(shape in cellShapes) {
            if(collisionShape != shape) {
                result = Collisions.test(collisionShape, shape);
                if(result.isColliding) {
                    break;
                }
                else {
                    result = null;
                }
            }
        }
        
        collisionShape.overridePosition = prevOverride;

        return result;
    }

    // & Returns the first collision for multiple shapes
    public extern overload inline function getCollisionAt(collisionShapes: Array<CollisionShape>, ?position: Vec2): CollisionInfo {
        var result: CollisionInfo = null;
        
        for(collisionShape in collisionShapes) {
            var prevOverride: Vec2 = collisionShape.overridePosition;
            if(position != null) 
                collisionShape.overridePosition = position;

            var cellShapes = getShapesFromBounds(collisionShape.bounds);
            for(shape in cellShapes) {
                if(!collisionShapes.contains(shape)) {
                    result = Collisions.test(collisionShape, shape);
                    if(result.isColliding) {
                        break;
                    }
                    else {
                        result = null;
                    }
                }
            }
            
            collisionShape.overridePosition = prevOverride;
        }
        
        return result;
    }

    // & Returns all collisions for one shape
    public extern overload inline function getCollisionsAt(collisionShape: CollisionShape, ?position: Vec2): Array<CollisionInfo> {
        var results: Array<CollisionInfo> = [];
        
        var prevOverride: Vec2 = collisionShape.overridePosition;
        if(position != null) 
            collisionShape.overridePosition = position;
        
        var cellShapes = getShapesFromBounds(collisionShape.bounds);
        for(shape in cellShapes) {
            if(collisionShape != shape) {
                var result = Collisions.test(collisionShape, shape);
                if(result.isColliding) {
                    results.push(result);
                }
            }
        }
        
        collisionShape.overridePosition = prevOverride;

        return results;
    }

    // & Returns all collisions for multiple shapes
    public extern overload inline function getCollisionsAt(collisionShapes: Array<CollisionShape>, ?position: Vec2): Array<CollisionInfo> {
        var results: Array<CollisionInfo> = [];
        
        for(collisionShape in collisionShapes) {
            var prevOverride: Vec2 = collisionShape.overridePosition;
            if(position != null) 
                collisionShape.overridePosition = position;

            var cellShapes = getShapesFromBounds(collisionShape.bounds);
            for(shape in cellShapes) {
                if(!collisionShapes.contains(shape)) {
                    var result = Collisions.test(collisionShape, shape);
                    if(result.isColliding) {
                        results.push(result);
                    }
                }
            }
            
            collisionShape.overridePosition = prevOverride;
        }
        return results;
    }

    // & Returns a raycast result closest to the ray origin
    public extern overload inline function getCollisionsAt(rayCast: Raycast): RayResult {
        var result: RayResult = {
            intersectionPoint: null,
            shape: null
        };
        
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
            var rayResult: Vec2 = Collisions.raycastTest(rayCast, shape);
            if(rayResult != null && (result.intersectionPoint == null || rayResult.distance(rayCast.origin) < result.intersectionPoint.distance(rayCast.origin))) {
                result.intersectionPoint = rayResult;
                result.shape = shape;
            }
        }
        
        return result;
    }

    // & Returns all raycast results
    public extern overload inline function getCollisionsAt(rayCast: Raycast, results: Array<RayResult>): Int {
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
            var rayResult: Vec2 = Collisions.raycastTest(rayCast, shape);
            if(rayResult != null) {
                results.push({intersectionPoint: rayResult, shape: shape});
                count++;
            }
        }
        
        return count;
    }

    public function representShapes(layers: h2d.Layers, layer: Int, showBonds: Bool = false) {
        shapeRender.clear();

        for(shape in shapes) {
            shapeRender.lineStyle(1, 0x00FF00);

            switch(Type.getClass(shape)) {
                case CollisionAABB:
                    var bounds: Bounds = shape.bounds;
                    shapeRender.drawRect(bounds.min.x, bounds.min.y, bounds.max.x - bounds.min.x, bounds.max.y - bounds.min.y);
                case CollisionPolygon:
                    var poly: CollisionPolygon = cast shape;
                    var vertices: Array<Vec2> = poly.worldVertices;
                    for(i in 0...vertices.length) {
                        var vert = vertices[i];
                        var nextVert = vertices[(i + 1)%vertices.length];
                        shapeRender.moveTo(vert.x, vert.y);
                        shapeRender.lineTo(nextVert.x, nextVert.y);
                    }
                case CollisionCircle:
                    var circle: CollisionCircle = cast shape;
                    var pos = shape.getAbsPosition();
                    shapeRender.drawCircle(pos.x, pos.y, circle.radius);
            }
        }
        
        layers.add(shapeRender, layer);
    }
}