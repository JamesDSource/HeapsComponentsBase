package base.comp;

import base.math.Vector2;
import base.comp.Component;

class Transform2D implements Component {
    public var parentEntity: Entity = null;
    @:readOnly public var updateable = false;
    public function update(delta: Float): Void {};

    public var position: Vector2;

    public function new(?position: Vector2) {
        this.position = position == null ? new Vector2() : position;
    }
}