package hcb.comp;

import VectorMath;
import hcb.comp.Component;

class Transform2D extends Component {
    private var position: Vec2;
    private var eventListeners: Array<(Vec2, Vec2) -> Void> = new Array<(Vec2, Vec2) -> Void>();

    public function new(name: String, ?position: Vec2) {
        super(name);
        updateable = false;

        this.position = position == null ? vec2(0, 0) : position;
    }

    public function getPosition(): Vec2 {
        return position.clone();
    }

    public function move(moveVector: Vec2) {
        var ev = moveEventCall.bind(_, position.clone());
        position += moveVector;
        ev(position.clone());
    }

    public function moveTo(position: Vec2) {
        var ev = moveEventCall.bind(_, position.clone());
        this.position = position.clone();
        ev(position.clone());
    }

    public function moveEventSubscribe(callBack: (Vec2, Vec2) -> Void) {
        eventListeners.push(callBack);
    }

    public function moveEventRemove(callBack: (Vec2, Vec2) -> Void) {
        eventListeners.remove(callBack);
    }

    private function moveEventCall(to: Vec2, from: Vec2) {
        for(listener in eventListeners) {
            listener(to, from);
        }
    }
}