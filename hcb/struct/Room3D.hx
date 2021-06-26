package hcb.struct;

import h3d.scene.Scene;

class Room3D extends Room {
    public var scene(default, null): Scene;

    public function new() {
        super();
        scene = new Scene();
    }

    public override function clear() {
        super.clear();

        scene.dispose();
        scene = new Scene();
    }
}