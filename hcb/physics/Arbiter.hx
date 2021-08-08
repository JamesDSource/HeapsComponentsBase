package hcb.physics;

import hcb.comp.Body;
import VectorMath;

using hcb.math.Vector;

class Contact {
    public var position: Vec2;
    public var normal: Vec2;
    public var penetration: Float;

    public var arm1: Vec2 = null; 
    public var arm2: Vec2 = null;
    public var massNormal: Float;
    public var massTangent: Float;

    public var bias: Float = 0;     // For position correction
    public var pn: Float = 0;       // Accumulated normal impulse
    public var pt: Float = 0;       // Accumulated tangent impulse
    public var pnb: Float = 0;      // Accumulated normal impulse for position bias

    public function new(position: Vec2, normal: Vec2, penetration: Float) {
        this.position = position.clone();
        this.normal = normal.clone();
        this.penetration = penetration;
    }

}

class Arbiter {
    public var b1: Body;
    public var b2: Body;
    private var contacts: Array<Contact> = [];
    private var e: Float = 0;
    private var fric: Float = 0;

    public function new(b1: Body, b2: Body, ?contacts: Array<Contact>) {
        this.b1 = b1;
        this.b2 = b2;

        if(contacts != null)
            update(contacts);
    }

    public function update(contacts: Array<Contact>) {
        this.contacts = contacts.copy();
    }

    public function preCompile(dt: Float, positionCorrection: Float = 0, slop: Float = 0) {
        e = Math.min(b1.elasticity, b2.elasticity);
        fric = Math.sqrt(b1.friction*b2.friction);

        var pos1: Vec2 = b1.shape.getAbsPosition();
        var pos2: Vec2 = b2.shape.getAbsPosition();
        
        for(contact in contacts) {
            var r1 = contact.arm1 = contact.position - pos1;
            var r2 = contact.arm2 = contact.position - pos2;

            // Mass normal
            var rn1 = r1.dot(contact.normal);
            var rn2 = r2.dot(contact.normal);
            var massNormal = b1.inverseMass + b2.inverseMass + b1.inverseInertia*(dot(r1, r1) - rn1*rn1) + b2.inverseInertia*(dot(r2, r2) - rn2*rn2);
            contact.massNormal = 1/massNormal;

            // Mass tangent
            var tangent: Vec2 = contact.normal.crossLeft();
            var rt1 = r1.dot(tangent);
            var rt2 = r2.dot(tangent);
            var massTangent = b1.inverseMass + b2.inverseMass + b1.inverseInertia*(dot(r1, r1) - rt1*rt1) + b2.inverseInertia*(dot(r2, r2) - rt2*rt2);
            contact.massTangent = 1/massTangent;

            // Bias
            contact.bias = positionCorrection*(1/dt)*Math.max(0., contact.penetration - slop);

            // Accumulated normal + friction impulse
            var accumulated: Vec2 = contact.pn*contact.normal + contact.pt*tangent;
            b1.impulse(-accumulated, r1);
            b2.impulse( accumulated, r2);
        }
    }

    public function applyImpulse() {
        var invMass1: Float = b1.inverseMass;
        var invMass2: Float = b2.inverseMass;
        var invInertia1: Float = b1.inverseInertia;
        var invInertia2: Float = b2.inverseInertia;

        var pos1: Vec2 = b1.shape.getAbsPosition();
        var pos2: Vec2 = b2.shape.getAbsPosition();
        
        // Loop through every point of contact
        for(contact in contacts) {
            var r1 = contact.arm1;
            var r2 = contact.arm2;

            // Getting the relative velocity between the two points
            // This accounts for both linear and rotational velocity
            var relative: Vec2 =    (b2.velocity + r2.crossRight(b2.angularVelocity)) - 
                                    (b1.velocity + r1.crossRight(b1.angularVelocity));
            var velAlongNormal: Float = relative.dot(contact.normal);
            if(velAlongNormal > 0)
                continue;

            var j = contact.massNormal*(-(e + 1)*velAlongNormal + contact.bias);

            // Clamping the accumulated impulse
            var pn0 = contact.pn;
            contact.pn = Math.max(pn0 + j, 0);
            velAlongNormal = contact.pn - pn0;

            var impulse = j*contact.normal/contacts.length;
            b1.impulse(-impulse, r1);
            b2.impulse( impulse, r2);

            // Friction
            var relative: Vec2 =    (b2.velocity + r2.crossRight(b2.angularVelocity)) - 
                                    (b1.velocity + r1.crossRight(b1.angularVelocity));
            
            var tangent = contact.normal.crossLeft();
            var velAlongTangent: Float = tangent.dot(relative);

            var jt: Float = -velAlongTangent*contact.massTangent;

            // Clamping the accumulated impulse
            var maxPt = fric*contact.pn;
            var oldTangentImpulse = contact.pt;
            contact.pt = hxd.Math.clamp(oldTangentImpulse + jt, -maxPt, maxPt);
            jt = contact.pt - oldTangentImpulse;

            // Apply friction
            var friction: Vec2 = jt*tangent;
            b1.impulse(-friction, r1);
            b2.impulse( friction, r2);
        }
    }

    public function getContactPoints(): Array<Vec2> {
        return [
            for(contact in contacts)
                contact.position
        ];
    }
}