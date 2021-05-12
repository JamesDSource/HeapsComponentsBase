package hcb.comp;

import hcb.math.Vector;
import VectorMath;
import hcb.comp.col.*;

typedef BodyOptions = {
    ?shape: CollisionShape,

    ?velocity: Vec2,
    ?mass: Null<Float>,

    ?angle: Null<Float>,
    ?angularVelocity: Null<Float>,
    ?angularInertia: Null<Float>,

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

    // * Angular components
    public var angle(default, set): Float = 0;
    // ^ Measured in radians
    public var angularVelocity: Float = 0;
    public var angularInertia: Float = 0;
    public var inverseAngularInertia(get, null): Float;
    public var syncPolygonRotation: Bool = true;

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

    private inline function set_angle(angle: Float): Float {
        this.angle = angle;
        
        if(syncPolygonRotation && Std.isOfType(shape, CollisionPolygon)) {
            var polygon: CollisionPolygon = cast shape;
            polygon.rotation = angle;
        }
        
        return angle;
    }

    private inline function get_inverseAngularInertia(): Float {
        return angularInertia == 0 ? 0 : 1/angularInertia;
    }

    public function new(name: String, options: BodyOptions) {
        super(name);
        setOptions(options);
        updateable = false;
    }

    // & Sets body properties
    public function setOptions(options: BodyOptions) {
        if(options.shape != null) {
            shape = options.shape;
        }

        if(options.velocity != null) {
            velocity = options.velocity.clone();
        }

        if(options.mass != null) {
            mass = options.mass;
        }

        if(options.angle != null) {
            angle = options.angle;
        }

        if(options.angularVelocity != null) {
            angularVelocity = options.angularVelocity;
        }

        if(options.angularInertia != null) {
            angularInertia = options.angularInertia;
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
    }

    // & Updates position and angle
    public function physicsUpdate() {
        if(mass == 0 || parentEntity == null) return;

        parentEntity.move(velocity);
        angle += angularVelocity;
    }

    // & Applies an impulse on a certain point of the shape
    public function impulse(force: Vec2, ?contactArm: Vec2) { 
        var acceleration = force*inverseMass;
        velocity += acceleration;

        if(contactArm == null) {
            contactArm = vec2(0, 0);
        }

        var torque = inverseAngularInertia*Vector.cross(contactArm, force);
        angularVelocity += torque;
    }

    public override function addedToRoom() {
        room.physicsWorld.addBody(this);
    }

    public override function removedFromRoom() {
        room.physicsWorld.removeBody(this);
    }
}