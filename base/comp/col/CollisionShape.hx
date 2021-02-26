package base.comp.col;

import base.Project.PauseMode;
import hxsl.Types.Vec;
import base.math.Vector2;

class CollisionShape implements Component {
    public var parentEntity: Entity = null;
    public var updateable: Bool = false;
    public var name: String;
    public var pauseMode = PauseMode.idle;
    public function update(delta: Float): Void {}

    public var active: Bool = true;
    private var radius: Float = 0;

    public var tags: Array<String> = [];
    public var ignoreTags: Array<String> = [];

    public var offset: Vector2 = new Vector2();

    public var collisionWorld: CollisionWorld;

    public function new(name: String) {
        this.name = name;
    }

    public function init() {
        if(parentEntity.project != null) {
            collisionWorld = parentEntity.project.collisionWorld;
            collisionWorld.shapes.push(this);
        }
    }

    public function onDestroy() {
        if(collisionWorld != null) {
            collisionWorld.shapes.remove(this);
        }
    }

    public function getAbsPosition(): Vector2 {
        if(parentEntity == null) {
            return offset;
        }
        else {
            var transform: Transform2D = cast parentEntity.getSingleComponentOfType(Transform2D);
            if(transform != null) {
                return transform.position.add(offset);
            }
            else {
                return offset;
            }
        }
    }

    public function getRadius(): Float {
        return radius;
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
        if(!Collisions.radiusIntersection(absPos1, absPos2, getRadius(), shape.getRadius())) {
            return false;
        }

        return true;
    }

    public function getBounds(): {topLeft: Vector2, bottomRight: Vector2} {
        return {topLeft: new Vector2(), bottomRight: new Vector2()};
    }
}