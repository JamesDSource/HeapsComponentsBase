package hcb.comp.col;

import hcb.Project.PauseMode;
import hxsl.Types.Vec;
import hcb.math.Vector2;

typedef Bounds = {
    min: Vector2,
    max: Vector2
}

class CollisionShape extends Component {
    public var active: Bool = true;
    public var bounds(get, null): Bounds = {min: new Vector2(), max: new Vector2()};

    public var tags: Array<String> = [];
    public var ignoreTags: Array<String> = [];

    public var offset: Vector2 = new Vector2();

    public var overridePosition: Vector2 = null;

    public var collisionWorld: CollisionWorld;

    public function new(name: String) {
        super(name);
        updateable = true;
    }

    private dynamic function get_bounds(): Bounds {
        return {min: new Vector2(), max: new Vector2()};
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
            var transform: Transform2D = cast parentEntity.getComponentOfType(Transform2D);
            if(transform != null) {
                return transform.getPosition().add(offset);
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

        // * Checking if the bounds intersect
        if(!Collisions.boundsIntersection(bounds, shape.bounds)) {
            return false;
        }

        return true;
    }
}