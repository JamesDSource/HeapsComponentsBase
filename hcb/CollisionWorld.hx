package hcb;
import hcb.comp.col.*;
import hcb.math.Vector2;

class CollisionWorld {
    public var shapes: Array<CollisionShape> = [];

    function isCollisionAt(colShape: CollisionShape, position: Vector2) {
        var returnResult: Bool = false;
        
        var prevOverride: Vector2 = colShape.overridePosition;
        colShape.overridePosition = position;
        for(shape in shapes) {
            if(Collisions.test(colShape, shape)) {
                returnResult = true;
                break;
            }
        }
        colShape.overridePosition = prevOverride;

        return returnResult;
            
    }

    public function new() {}
}