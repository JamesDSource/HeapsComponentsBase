package hcb.comp;

import VectorMath;
import hcb.comp.col.*;

typedef BodyOptions = {
    ?shape: CollisionShape,
    ?mass: Null<Float>,
    ?elasticity: Null<Float>,
    ?staticFriction: Null<Float>,
    ?dynamicFriction: Null<Float>,
    ?velocity: Vec2,
    ?angularVelocity: Null<Float>
}

class Body extends Component {
    public var forceAccum: Vec2 = vec2(0, 0);
    public var velocity: Vec2 = vec2(0, 0);
    public var angularVelocity: Float = 0;
    public var linearDamping: Float = 0;
    public var angularDamping: Float = 0;

    public var shape(default, set): CollisionShape = null;
    public var mass: Float = 0;
    public var inverseMass(get, null): Float;
    public var infiniteMass(get, null): Bool;
    public var elasticity: Float = 1.0;
    public var staticFriction: Float = 1.0;
    public var dynamicFriction: Float = 1.0;

    private inline function set_shape(shape: CollisionShape): CollisionShape {
        if(shape != null) {
            if(shape.body != null) {
                shape.body.shape = null;
            }
            shape.body = this;
        }
        else if(this.shape != null) {
            this.shape.body = null;
        }
        
        this.shape = shape;
        return shape;
    }

    private inline function get_inverseMass(): Float {
        return mass == 0 ? 0 : 1/mass;
    }

    private inline function get_infiniteMass(): Bool {
        return mass == 0;
    }

    public function new(name: String, options: BodyOptions) {
        super(name);
        setOptions(options);
        updateable = false;
    }

    public function setOptions(options: BodyOptions) {
        if(options.shape != null) {
            shape = options.shape;
        }

        if(options.mass != null) {
            mass = options.mass;
        }
        
        if(options.elasticity != null) {
            elasticity = options.elasticity;
        }

        if(options.staticFriction != null) {
            staticFriction = options.staticFriction;
        }

        if(options.dynamicFriction != null) {
            dynamicFriction = options.dynamicFriction;
        }

        if(options.velocity != null) {
            velocity = options.velocity.clone();
        }

        if(options.angularVelocity != null) {
            angularVelocity = options.angularVelocity;
        } 
    }

    public function physicsUpdate() {
        if(mass == 0 || parentEntity == null) return;

        var acceleration: Vec2 = forceAccum*inverseMass;
        velocity += acceleration;
        parentEntity.move(velocity);

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