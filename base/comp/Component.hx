package base.comp;

import h2d.Object;

interface Component {
    public var parentEntity: base.Entity;
    public var updateable: Bool;
    public function update(delta: Float): Void;
}