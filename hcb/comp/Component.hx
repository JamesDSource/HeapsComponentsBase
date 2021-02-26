package hcb.comp;

import hcb.Project.PauseMode;
import h2d.Object;

interface Component {
    // * Read only, do not change manually
    public var parentEntity: hcb.Entity;
    public var updateable: Bool;
    public var name: String;
    public var pauseMode: PauseMode;

    // & called when the component is added to an entity
    public function init(): Void;

    // & Called automatically by the Project class every frame if updateable
    public function update(delta: Float): Void;

    // & Called when the component is removed
    public function onDestroy(): Void;
}