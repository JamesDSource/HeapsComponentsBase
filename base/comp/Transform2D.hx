package base.comp;

import base.math.Vector2;
import base.comp.Component;

class Transform2D implements Component {
    public var parentEntity: Entity = null;
    public var updateable = false;
    public var name: String;
    public var pauseMode = base.Project.PauseMode.idle;
    public function init() {}
    public function onDestroy() {}
    public function update(delta: Float): Void {}

    public var position: Vector2;

    public function new(name: String, ?position: Vector2) {
        this.name = name;
        this.position = position == null ? new Vector2() : position;
    }
}