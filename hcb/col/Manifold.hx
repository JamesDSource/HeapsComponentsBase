package hcb.col;

import hcb.physics.Arbiter.Contact;

class Manifold {
    public var normal: Vec2 = null;
    public var penetration: Null<Float> = null;
    public var contactPoints: Array<Vec2> = [];

    public function new() {}
    
    public function copy(manifold: Manifold) {
        normal = manifold.normal.clone();
        penetration = manifold.penetration;
        contactPoints = [];
        for(point in manifold.contactPoints)
            contactPoints.push(point.clone());
    }

    public function convertToContacts(): Array<Contact> {
        return [
            for(point in contactPoints)
                new Contact(point, normal, penetration)
        ];
    }
}