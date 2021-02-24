package base.comp.col;

import base.comp.Component.ComponentType;
import base.math.Vector2;

class CollisionShape implements Component {
    public var parentEntity: Entity = null;
    public var updateable: Bool = false;
    public function init() {}
    public function update(delta: Float): Void {}

    public var active: Bool = true;
    private var radius: Float = 0;

    public var tags: Array<String> = [];
    public var ignoreTags: Array<String> = [];

    public var offset: Vector2 = new Vector2();

    public function new() {

    }

    public function getAbsPosition(): Vector2 {
        if(parentEntity == null) {
            return null;
        }
        else {
            var transforms: Array<Transform2D> = cast parentEntity.getComponentsOfType(Transform2D);
            if(transforms.length > 0) {
                return transforms[0].position.add(offset);
            }
            else {
                return null;
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
}