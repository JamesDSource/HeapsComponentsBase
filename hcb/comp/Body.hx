package hcb.comp;

import hcb.physics.PhysicsWorld;
import VectorMath;
import hcb.comp.col.*;

using hcb.math.Vector;

typedef BodyOptions = {
    ?shape: CollisionShape,

    ?velocity: Vec2,
    ?mass: Null<Float>,
    ?linearDrag: Null<Float>,

    ?angularVelocity: Null<Float>,
    ?angularInertia: Null<Float>,
    ?angularDrag: Null<Float>,

    ?elasticity: Null<Float>,
    ?staticFriction: Null<Float>,
    ?dynamicFriction: Null<Float>,
    
    
}

class Body extends Component {
    public var shape(default, set): CollisionShape = null;
    
    // * Linear components
    public var velocity: Vec2 = vec2(0, 0);
    public var mass: Float = 0;
    public var inverseMass(get, null): Float;
    public var infiniteMass(get, null): Bool;
    public var linearDrag(default, set): Float = 1.;

    // * Angular components
    public var angularVelocity: Float = 0;
    public var angularInertia: Float = 0;
    public var inverseAngularInertia(get, null): Float;
    public var angularDrag(default, set): Float = 1.;
    public var syncPolygonRotation: Bool = true;

    public var elasticity: Float = 1.;
    public var staticFriction: Float = 0;
    public var dynamicFriction: Float = 0;

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

    private inline function set_linearDrag(linearDrag: Float): Float {
        this.linearDrag = hxd.Math.clamp(linearDrag, 0.0, 1.0);
        return this.linearDrag;
    }

    private inline function get_inverseAngularInertia(): Float {
        return angularInertia == 0 ? 0 : 1/angularInertia;
    }

    private inline function set_angularDrag(angularDrag: Float): Float {
        this.angularDrag = hxd.Math.clamp(angularDrag, 0.0, 1.0);
        return this.angularDrag;
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

        if(options.linearDrag != null)
            linearDrag = options.linearDrag;

        if(options.angularVelocity != null)
            angularVelocity = options.angularVelocity;

        if(options.angularInertia != null)
            angularInertia = options.angularInertia;

        if(options.angularDrag != null)
            angularDrag = options.angularDrag;
        
        if(options.elasticity != null)
            elasticity = options.elasticity;

        if(options.staticFriction != null)
            staticFriction = options.staticFriction;

        if(options.dynamicFriction != null)
            dynamicFriction = options.dynamicFriction; 
    }

    // & Updates position and angle
    @:allow(hcb.physics.PhysicsWorld.update)
    private function physicsUpdate() {
        if(parentEntity == null) return;

        parent2d.transform.rotateRad(angularVelocity);
        parent2d.transform.translate(velocity);

        velocity *= linearDrag;
        angularVelocity *= angularDrag;
    }

    // & Applies an impulse on a certain point of the shape
    public function impulse(force: Vec2, ?contactArm: Vec2) { 
        velocity += force*inverseMass;

        if(contactArm == null)
            contactArm = vec2(0, 0);

        angularVelocity += inverseAngularInertia*contactArm.cross(force);
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