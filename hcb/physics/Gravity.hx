package hcb.physics;

import hcb.comp.Body;
import VectorMath;

class Gravity implements ForceGenerator {

    public static var gravity(default, null): Vec2 = vec2(0, 0);
    private var gravityOverride: Vec2;

    public function new(?gravityOverride) {
        this.gravityOverride = gravityOverride;
    }

    public function updateForce(body: Body) {
        var grav = gravityOverride != null ? gravityOverride : gravity;
        body.impulse(grav*body.mass);
    }
}