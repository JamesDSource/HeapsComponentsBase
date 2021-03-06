package hcb.comp.col;

import hcb.Project.PauseMode;
import hxsl.Types.Vec;
import hcb.math.Vector2;

class CollisionShape extends Component {
    public var active: Bool = true;
    public var radius(default, null): Float = 0;

    public var tags: Array<String> = [];
    public var ignoreTags: Array<String> = [];

    public var offset: Vector2 = new Vector2();
    public var overridePosition: Vector2 = null;

    public var collisionWorld: CollisionWorld;

    public function new(name: String) {
        super(name);
        updateable = true;
    }

    public override function init() {
        if(project != null) {
            collisionWorld = project.collisionWorld;
            collisionWorld.shapes.push(this);
        }
    }

    public override function onDestroy() {
        if(collisionWorld != null) {
            collisionWorld.shapes.remove(this);
        }
    }

    public function getAbsPosition(): Vector2 {
        if(overridePosition != null) {
            return overridePosition.add(offset);
        }
        
        if(parentEntity == null) {
            return offset.clone();
        }
        else {
            var transform: Transform2D = cast parentEntity.getSingleComponentOfType(Transform2D);
            if(transform != null) {
                return transform.position.add(offset);
            }
            else {
                return offset.clone();
            }
        }
    }

    public function canInteractWith(shape: CollisionShape): Bool {
        // * Checking for tags
        for(tag in shape.tags) {
            if(ignoreTags.contains(tag)) {
                return false;
            }
        }

        var absPos1 = getAbsPosition();
        var absPos2 = shape.getAbsPosition();

        // * Checking if both have positions
        if(absPos1 == null || absPos2 == null) {
            return false;
        }

        // * Checking if there is a radius intersection
        if(!Collisions.radiusIntersection(absPos1, absPos2, radius, shape.radius)) {
            return false;
        }

        return true;
    }

    public function getBounds(): {topLeft: Vector2, bottomRight: Vector2} {
        return {topLeft: new Vector2(), bottomRight: new Vector2()};
    }
}