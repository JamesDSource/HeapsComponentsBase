package hcb;
import hcb.comp.col.CollisionShape.Bounds;
import hcb.comp.col.*;
import VectorMath;
import hcb.SignedArray;

class CollisionWorld {
    private var shapes: Array<CollisionShape> = [];
    private var renderAssets = new h2d.Object();

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

    public function isCollisionAt(colShape: CollisionShape, position: Vec2): Bool {
        var returnResult: Bool = false;

        var prevOverride: Vec2 = colShape.overridePosition;
        colShape.overridePosition = position;
        var cellShapes = getShapesFromBounds(colShape.bounds);
        for(shape in cellShapes) {
            if(colShape != shape && Collisions.test(colShape, shape)) {
                returnResult = true;
                break;
            }
        }
        colShape.overridePosition = prevOverride;
        return returnResult;
            
    }

    public function isAnyCollisionAt(colShapes: Array<CollisionShape>, position: Vec2): Bool {
        var returnResult: Bool = false;
        
        for(colShape in colShapes) {
            var prevOverride: Vec2 = colShape.overridePosition;
            colShape.overridePosition = position;
            var cellShapes = getShapesFromBounds(colShape.bounds);
            for(shape in cellShapes) {
                if(!colShapes.contains(shape) && Collisions.test(colShape, shape)) {
                    returnResult = true;
                    break;
                }
            }
            colShape.overridePosition = prevOverride;
        }
        return returnResult;
    }

    public function getCollisionAt(colShape: CollisionShape, position: Vec2): Array<CollisionShape> {
        var returnResult: Array<CollisionShape> = [];
        
        var prevOverride: Vec2 = colShape.overridePosition;
        colShape.overridePosition = position;
        var cellShapes = getShapesFromBounds(colShape.bounds);
        for(shape in cellShapes) {
            if(colShape != shape && Collisions.test(colShape, shape)) {
                returnResult.push(shape);
            }
        }
        colShape.overridePosition = prevOverride;

        return returnResult;
            
    }

    public function getAnyCollisionAt(colShapes: Array<CollisionShape>, position: Vec2): Array<CollisionShape> {
        var returnResult: Array<CollisionShape> = [];
        
        for(colShape in colShapes) {
            var prevOverride: Vec2 = colShape.overridePosition;
            colShape.overridePosition = position;
            var cellShapes = getShapesFromBounds(colShape.bounds);
            for(shape in cellShapes) {
                if(!returnResult.contains(shape) && !colShapes.contains(shape) && Collisions.test(colShape, shape)) {
                    returnResult.push(shape);
                }
            }
            colShape.overridePosition = prevOverride;
        }
        return returnResult;
    }

    public function pushOut(colShape: CollisionShape, position: Vec2, maxSteps: Int = 100): Vec2 {
        for(i in 0...maxSteps) {
            if(!isCollisionAt(colShape, vec2(i, 0) + position)) {
                return vec2(i, 0);
            }
            else if(!isCollisionAt(colShape, vec2(-i, 0) + position)) {
                return vec2(-i, 0);
            }
            else if(!isCollisionAt(colShape, vec2(0, i) + position)) {
                return vec2(0, i);
            }
            else if(!isCollisionAt(colShape, vec2(0, -i) + position)) {
                return vec2(0, -i);
            }
            else if(!isCollisionAt(colShape, vec2(i, i) + position)) {
                return vec2(i, i);
            }
            else if(!isCollisionAt(colShape, vec2(-i, i) + position)) {
                return vec2(-i, i);
            }
            else if(!isCollisionAt(colShape, vec2(i, -i) + position)) {
                return vec2(i, -i);
            }
            else if(!isCollisionAt(colShape, vec2(-i, -i) + position)) {
                return vec2(-i, -i);
            }
        }
        return vec2(0, 0);
    }

    public function pushOutDirection(colShape: CollisionShape, position: Vec2, direction: Vec2, maxSteps: Int = 100): Vec2 {
        var pushValue = vec2(0, 0);
        var normalizedDir = normalize(pushValue);

        var steps: Int = 0;
        while(isCollisionAt(colShape, position + pushValue)) {
            steps++;
            if(steps >= maxSteps) {
                return vec2(0, 0);
            }

            pushValue += normalizedDir;
        }

        return pushValue;
    }

    public function representBoundingBoxes(layers: h2d.Layers, layer: Int) {
        renderAssets.removeChildren();

        for(shape in shapes) {
            var bounds: Bounds = shape.bounds;

            var customGraphics: h2d.Graphics = new h2d.Graphics();
            customGraphics.lineStyle(3, 0xFFFFFF);
            customGraphics.drawRect(bounds.min.x, bounds.min.y, bounds.max.x - bounds.min.x, bounds.max.y - bounds.min.y);
            renderAssets.addChild(customGraphics);
        }
        
        layers.add(renderAssets, layer);
    }
}