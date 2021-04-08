package hcb;
import hcb.comp.col.CollisionShape.Bounds;
import hcb.comp.col.*;
import hcb.math.Vector2;

class CollisionWorld {
    public var shapes: Array<CollisionShape> = [];
    private var renderAssets = new h2d.Object();

    public function new() {

    }

    public function isCollisionAt(colShape: CollisionShape, position: Vector2): Bool {
        var returnResult: Bool = false;

        var prevOverride: Vector2 = colShape.overridePosition;
        colShape.overridePosition = position;
        for(shape in shapes) {
            if(colShape != shape && Collisions.test(colShape, shape)) {
                returnResult = true;
                break;
            }
        }
        colShape.overridePosition = prevOverride;
        return returnResult;
            
    }

    public function isAnyCollisionAt(colShapes: Array<CollisionShape>, position: Vector2): Bool {
        var returnResult: Bool = false;
        
        for(colShape in colShapes) {
            var prevOverride: Vector2 = colShape.overridePosition;
            colShape.overridePosition = position;
            for(shape in shapes) {
                if(!colShapes.contains(shape) && Collisions.test(colShape, shape)) {
                    returnResult = true;
                    break;
                }
            }
            colShape.overridePosition = prevOverride;
        }
        return returnResult;
    }

    public function getCollisionAt(colShape: CollisionShape, position: Vector2): Array<CollisionShape> {
        var returnResult: Array<CollisionShape> = [];
        
        var prevOverride: Vector2 = colShape.overridePosition;
        colShape.overridePosition = position;
        for(shape in shapes) {
            if(colShape != shape && Collisions.test(colShape, shape)) {
                returnResult.push(shape);
            }
        }
        colShape.overridePosition = prevOverride;

        return returnResult;
            
    }

    public function getAnyCollisionAt(colShapes: Array<CollisionShape>, position: Vector2): Array<CollisionShape> {
        var returnResult: Array<CollisionShape> = [];
        
        for(colShape in colShapes) {
            var prevOverride: Vector2 = colShape.overridePosition;
            colShape.overridePosition = position;
            for(shape in shapes) {
                if(!returnResult.contains(shape) && !colShapes.contains(shape) && Collisions.test(colShape, shape)) {
                    returnResult.push(shape);
                }
            }
            colShape.overridePosition = prevOverride;
        }
        return returnResult;
    }

    public function pushOut(colShape: CollisionShape, position: Vector2, maxSteps: Int = 100): Vector2 {
        for(i in 0...maxSteps) {
            if(!isCollisionAt(colShape, new Vector2(i, 0).add(position))) {
                return new Vector2(i, 0);
            }
            else if(!isCollisionAt(colShape, new Vector2(-i, 0).add(position))) {
                return new Vector2(-i, 0);
            }
            else if(!isCollisionAt(colShape, new Vector2(0, i).add(position))) {
                return new Vector2(0, i);
            }
            else if(!isCollisionAt(colShape, new Vector2(0, -i).add(position))) {
                return new Vector2(0, -i);
            }
            else if(!isCollisionAt(colShape, new Vector2(i, i).add(position))) {
                return new Vector2(i, i);
            }
            else if(!isCollisionAt(colShape, new Vector2(-i, i).add(position))) {
                return new Vector2(-i, i);
            }
            else if(!isCollisionAt(colShape, new Vector2(i, -i).add(position))) {
                return new Vector2(i, -i);
            }
            else if(!isCollisionAt(colShape, new Vector2(-i, -i).add(position))) {
                return new Vector2(-i, -i);
            }
        }
        return new Vector2();
    }

    public function pushOutDirection(colShape: CollisionShape, position: Vector2, direction: Vector2, maxSteps: Int = 100): Vector2 {
        var pushValue = new Vector2();
        var normalizedDir = direction.normalized();

        var steps: Int = 0;
        while(isCollisionAt(colShape, position.add(pushValue))) {
            steps++;
            if(steps >= maxSteps) {
                return new Vector2();
            }

            pushValue.addMutate(normalizedDir);
        }

        return pushValue;
    }

    public function representBoundingBoxes(layers: h2d.Layers, layer: Int): Void {
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