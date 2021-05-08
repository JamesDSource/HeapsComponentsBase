package hcb.physics;

interface ForceGenerator {
    public function updateForce(body: hcb.comp.Body): Void;
}