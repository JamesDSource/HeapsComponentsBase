package hcb.comp.col;

import hcb.col.*;
import VectorMath.vec2;
import VectorMath;

typedef Bounds = {
    min: Vec2,
    max: Vec2
}

class CollisionShape extends TransformComponent2D {
    public var active: Bool = true;
    public var bounds(get, null): Bounds;

    public var debugColor: Null<Int> = 0xFFFFFF;

    public var tags: Array<String> = [];
    public var ignoreTags: Array<String> = [];

    public var overridePosition: Vec2 = null;

    public var collisionWorld: CollisionWorld;
    private var cellsIn: Array<Array<CollisionShape>> = [];

    public var center(get, null): Vec2;

    public var body: Body = null;
    // ^ Variable only set inside of the body, do not set manually

    private function get_bounds(): Bounds {
        return {min: vec2(0, 0), max: vec2(0, 0)};
    }

    private function get_center(): Vec2 {
        return transform.getPosition();
    }

    public function new(name: String = "Collision Shape") {
        super(name);
        updateable = false;
        transform.onTranslated = (position) -> updateCollisionCells();
    }

    private override function addedToRoom() {
        var r2d = room2d;
        if(r2d != null)
            r2d.collisionWorld.addShape(this);
    }

    private override function removedFromRoom() {
        if(collisionWorld != null)
            collisionWorld.removeShape(this);
    }

    public function getSupportPoint(d: Vec2): Vec2 {
        return vec2(0, 0);
    }

    // & Checks if it can interact with another collision shape
    public function canInteractWith(shape: CollisionShape): Bool {
        // * Checking for tags
        for(tag in shape.tags) {
            if(ignoreTags.contains(tag))
                return false;
        }

        // * Checking if the bounds intersect
        if(!Collisions.boundsIntersection(bounds, shape.bounds))
            return false;

        return true;
    }

    // & Updates the position in the collision cell grid
    public function updateCollisionCells() {
        for(cell in cellsIn)
            cell.remove(this);

        if(collisionWorld != null)
            cellsIn = collisionWorld.setShapeFromBounds(bounds, this);
    }

    // & Draws the shape
    public function represent(g: h2d.Graphics, ?color: Int, alpha = 1.0) {
        g.lineStyle(1, color == null ? debugColor : color, alpha);
    }
}