package hcb.comp.col;

import VectorMath.vec2;
import VectorMath;

typedef Bounds = {
    min: Vec2,
    max: Vec2
}

class CollisionShape extends Component {
    public var active: Bool = true;
    public var bounds(get, null): Bounds;

    public var tags: Array<String> = [];
    public var ignoreTags: Array<String> = [];

    private var offset: Vec2 = vec2(0, 0);
    public var offsetX(default, set): Float = 0;
    public var offsetY(default, set): Float = 0;

    public var overridePosition: Vec2 = null;

    public var collisionWorld: CollisionWorld;
    private var cellsIn: Array<Array<CollisionShape>> = [];

    public var body: Body = null;
    // ^ Variable only set inside of the body, do not set manually

    public function new(name: String, ?offset: Vec2) {
        super(name);
        if(offset != null) {
            offsetX = offset.x;
            offsetY = offset.y;
        }
        updateable = true;
    }

    private dynamic function get_bounds(): Bounds {
        return {min: vec2(0, 0), max: vec2(0, 0)};
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
        parentEntity.onMoveEventSubscribe(onMove);
    }

    public override function onRemoved() {
        parentEntity.onMoveEventRemove(onMove);
    }

    public override function addedToRoom() {
        room.collisionWorld.addShape(this);
    }

    public override function removedFromRoom() {
        collisionWorld.removeShape(this);
    }

    public function getAbsPosition(acceptOverride: Bool = true): Vec2 {
        if(acceptOverride && overridePosition != null) {
            return overridePosition + offset;
        }
        
        if(parentEntity == null) {
            return offset.clone();
        }
        else {
            return parentEntity.getPosition() + offset;
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
    private function onMove(to: Vec2, from: Vec2) {
        updateCollisionCells();
    }
}