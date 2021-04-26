package hcb.comp;

import VectorMath;
import hcb.comp.col.*;

typedef BodyOptions = {
    shape: CollisionShape,
    ?mass: Null<Float>,
    ?elasticity: Null<Float>,
    ?velocity: Vec2,
    ?angularVelocity: Vec2
}

class Body extends Component {
    public var forceAccum: Vec2 = vec2(0, 0);
    public var velocity: Vec2 = vec2(0, 0);
    public var angularVelocity: Float = 0;
    public var linearDamping: Float = 0;
    public var angularDamping: Float = 0;

    public var mass: Float = 0;
    public var inverseMass(get, null): Float;

    private inline function get_inverseMass(): Float {
        return mass == 0 ? 0 : 1/mass;
    }

    public function new(name: String, options: BodyOptions) {
        super(name);
        updateable = false;
    }

    public function physicsUpdate(delta: Float) {
        if(mass == 0) return;

        var acceleration: Vec2 = forceAccum*inverseMass;
        velocity += acceleration*delta;
        parentEntity.move(velocity*delta);

        forceAccum = vec2(0, 0);
    }

    public override function addedToRoom() {
        room.physicsWorld.addBody(this);
    }

    public override function removedFromRoom() {
        room.physicsWorld.removeBody(this);
    }

    public function impulse(force: Vec2) {
        forceAccum += force;
    }
}