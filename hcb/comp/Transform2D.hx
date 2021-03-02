package hcb.comp;

import hcb.math.Vector2;
import hcb.comp.Component;

class Transform2D extends Component {
    public var position: Vector2;

    public function new(name: String, ?position: Vector2) {
        super(name);
        updateable = false;

        this.position = position == null ? new Vector2() : position;
    }
}