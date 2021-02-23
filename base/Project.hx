package base;

class Project {
    public var paused: Bool = false;

    public var entities: Array<Entity> = [];

    public var scene: h2d.Scene;
    public var renderables: h2d.Layers;

    public function new() {
        scene = new h2d.Scene();
        renderables = new h2d.Layers(scene);
    }

    public function addEntity(components: Array<base.comp.Component>) {
        var entity = new Entity(this);
        for(component in components) {
            entity.addComponent(component);
        }
    }

    public function update(delta: Float) {
        for(entity in entities) {
            entity.update(delta);
        }
    }
}