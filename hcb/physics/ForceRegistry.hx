package hcb.physics;

import hcb.physics.ForceGenerator;
import hcb.comp.Body;

typedef ForceRegisteration = {
    forceGenerator: ForceGenerator,
    body: Body
}

class ForceRegistry {
    private var registry: Array<ForceRegisteration> = [];

    public function new() {}

    public function add(forceGenerator: ForceGenerator, body: Body) {
        registry.push({forceGenerator: forceGenerator, body: body});
    }

    public function remove(forceGenerator: ForceGenerator, body: Body): Bool {
        for(register in registry) {
            if(register.forceGenerator == forceGenerator && register.body == body) {
                registry.remove(register);
                return true;
            }
        }
        return false;
    }

    public function clear() {
        registry = [];
    }

    public function updateForces() {
        for(register in registry) {
            register.forceGenerator.updateForce(register.body);
        }
    }

    // TODO: Impliment me
    public function zeroForces() {

    }
}