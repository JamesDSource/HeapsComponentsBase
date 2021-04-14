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

    private var offset: Vector2 = new Vector2();
    public var offsetX(default, set): Float = 0;
    public var offsetY(default, set): Float = 0;

    public var overridePosition: Vector2 = null;

    public var collisionWorld: CollisionWorld;
    private var cellsIn: Array<Array<CollisionShape>> = [];

    public function new(name: String, ?offset: Vector2) {
        super(name);
        if(offset != null) {
            offsetX = offset.x;
            offsetY = offset.y;
        }
        updateable = true;
    }

    private dynamic function get_bounds(): Bounds {
        return {min: new Vector2(), max: new Vector2()};
    }

    private function set_offsetX(offsetX: Float): Float {
        this.offsetX = offsetX;
        offset.x = offsetX;
        updateCollisionCells();
        return offsetX;
    }

    private function set_offsetY(offsetY: Float): Float {
        this.offsetX = offsetX;
        offset.y = offsetY;
        updateCollisionCells();
        return offsetY;
    }

    public override function init() {
        if(project != null) {
            project.collisionWorld.addShape(this);
        }

        parentEntity.componentAddedEventSubscribe(onComponentAdded);
        parentEntity.componentRemovedEventSubscribe(onComponentRemoved);

        var transform: Transform2D = cast parentEntity.getComponentOfType(Transform2D);
        if(transform != null) {
            transform.moveEventSubscribe(onMove);
        }
    }

    public override function onDestroy() {
        if(collisionWorld != null) {
            collisionWorld.removeShape(this);
        }

        parentEntity.componentAddedEventRemove(onComponentAdded);
        parentEntity.componentRemovedEventRemove(onComponentRemoved);

        var transform: Transform2D = cast parentEntity.getComponentOfType(Transform2D);
        if(transform != null) {
            transform.moveEventRemove(onMove);
        }
    }

    public function getAbsPosition(acceptOverride: Bool = true): Vector2 {
        if(acceptOverride && overridePosition != null) {
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

    // & Checks if it can interact with another collision shape
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

    // & Updates the position in the collision cell grid
    public function updateCollisionCells() {
        for(cell in cellsIn) {
            cell.remove(this);
        }

        if(collisionWorld != null) {
            cellsIn = collisionWorld.setShapeFromBounds(bounds, this);
        }
    }

    // & Event listener for when the Transform2D moves
    private function onMove(to: Vector2, from: Vector2) {
        updateCollisionCells();
    }

    // & Incase the transform is added later
    private function onComponentAdded(component: Component) {
        if(Std.isOfType(component, Transform2D)) {
            var transform: Transform2D = cast component;
            transform.moveEventSubscribe(onMove);
        }
    }

    // & If the transform gets removed, remove the event listener
    private function onComponentRemoved(component: Component) {
        if(Std.isOfType(component, Transform2D)) {
            var transform: Transform2D = cast component;
            transform.moveEventRemove(onMove);
        }
    }
}