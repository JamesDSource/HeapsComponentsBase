package hcb.comp;

import hcb.Project.PauseMode;
import h2d.Object;

class Component {
    // * Read only, do not change manually
    public var parentEntity: hcb.Entity;
    public var updateable: Bool = true;
    public var name: String;
    public var pauseMode: PauseMode = PauseMode.idle;

    public function new(name: String) {
        this.name = name;
    }

    // & called when the component is added to an entity
    public dynamic function init(): Void {

    }

    // & Called automatically by the Project class every frame if updateable
    public dynamic function update(delta: Float): Void {

    }

    // & Called when the component is removed
    public dynamic function onDestroy(): Void {

    }
}