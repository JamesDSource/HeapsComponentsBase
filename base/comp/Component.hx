package base.comp;

import h2d.Object;

interface Component {
    // * Read only, do not change manually
    public var parentEntity: base.Entity;
    public var updateable: Bool;

    // & called when the component is added to an entity
    public function init(): Void;

    // & Called automatically by the Project class every frame if updateable
    public function update(delta: Float): Void;
}