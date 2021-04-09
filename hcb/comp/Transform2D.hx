package hcb.comp;

import hcb.math.Vector2;
import hcb.comp.Component;

class Transform2D extends Component {
    private var position: Vector2;
    private var eventListeners: Array<(Vector2, Vector2) -> Void> = new Array<(Vector2, Vector2) -> Void>();

    public function new(name: String, ?position: Vector2) {
        super(name);
        updateable = false;

        this.position = position == null ? new Vector2() : position;
    }

    public function getPosition(): Vector2 {
        return position.clone();
    }

    public function move(moveVector: Vector2) {
        var ev = moveEvent.bind(_, position.clone());
        position.addMutate(moveVector);
        ev(position.clone());
    }

    public function moveTo(position: Vector2) {
        var ev = moveEvent.bind(_, position.clone());
        this.position = position.clone();
        ev(position.clone());
    }

    public function moveEventAdd(callBack: (Vector2, Vector2) -> Void) {
        eventListeners.push(callBack);
    }

    public function moveEventRemove(callBack: (Vector2, Vector2) -> Void) {
        eventListeners.remove(callBack);
    }

    private function moveEvent(to: Vector2, from: Vector2) {
        for(listener in eventListeners) {
            listener(to, from);
        }
    }
}