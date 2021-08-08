package hcb.comp;

import hcb.physics.PhysicsWorld;
import VectorMath;
import hcb.comp.col.*;

using hcb.math.Vector;

typedef BodyOptions = {
    ?shape: CollisionShape,

    ?velocity: Vec2,
    ?mass: Null<Float>,

    ?angularVelocity: Null<Float>,
    ?inertia: Null<Float>,

    ?elasticity: Null<Float>,
    ?friction: Null<Float>
}

class Body extends Component {
    public var shape(default, set): CollisionShape = null;
    
    // * Linear components
    public var velocity: Vec2 = vec2(0, 0);
    public var mass: Float = 1;
    public var inverseMass(get, null): Float;
    public var infiniteMass(get, null): Bool;

    // * Angular components
    public var angularVelocity: Float = 0;
    public var inertia: Float = 1;
    public var inverseInertia(get, null): Float;
    public var syncPolygonRotation: Bool = true;

    public var elasticity: Float = 0;
    public var friction: Float = .2;

    private inline function set_shape(shape: CollisionShape): CollisionShape {
        if(shape != null) {
            if(shape.body != null)
                shape.body.shape = null;
            shape.body = this;
        }
        else if(this.shape != null) 
            this.shape.body = null;
        
        this.shape = shape;
        return shape;
    }

    private inline function get_inverseMass(): Float {
        return mass == 0 ? 0 : 1/mass;
    }

    private inline function get_infiniteMass(): Bool {
        return mass == 0;
    }

    private inline function get_inverseInertia(): Float {
        return inertia == 0 ? 0 : 1/inertia;
    }


    public function new(options: BodyOptions, name: String = "Body") {
        super(name);
        setOptions(options);
        updateable = false;
    }

    // & Sets body properties
    public function setOptions(options: BodyOptions) {
        if(options.shape != null) 
            shape = options.shape;

        if(options.velocity != null)
            velocity = options.velocity.clone();

        if(options.mass != null) 
            mass = options.mass;

        if(options.angularVelocity != null)
            angularVelocity = options.angularVelocity;

        if(options.inertia != null)
            inertia = options.inertia;
        
        if(options.elasticity != null)
            elasticity = options.elasticity;

        if(options.friction != null)
            friction = options.friction;
    }

    // & Updates position and angle
    @:allow(hcb.physics.PhysicsWorld)
    private function step(dt: Float) {
        if(parentEntity == null) return;

        parent2d.transform.rotateRad(angularVelocity*dt);
        parent2d.transform.translate(velocity*dt);
    }

    // & Applies an impulse on a certain point of the shape
    public function impulse(force: Vec2, ?contactArm: Vec2) { 
        velocity += force*inverseMass;

        if(contactArm != null)
            angularVelocity += inverseInertia*contactArm.cross(force);
    }

    private override function addedToRoom() {
        if(room2d != null)
            room2d.physicsWorld.addBody(this);
    }

    private override function removedFromRoom() {
        if(room2d != null)
            room2d.physicsWorld.removeBody(this);
    }
}