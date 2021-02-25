package base;

// ^ Project acts as the manager for everything
class Project {
    public var paused: Bool = false;

    public var entities: Array<Entity> = [];

    public var scene: h2d.Scene = null;
    public var renderables: h2d.Layers;

    public var camera: h2d.Camera;

    public var collisionWorld: CollisionWorld = new CollisionWorld();

    public function new() {
        resetScene();
        renderables = new h2d.Layers(scene);

        camera.anchorX = 0.5;
        camera.anchorY = 0.5;
    }

    public function addEntity(components: Array<base.comp.Component>) {
        var entity = new Entity(this);
        for(component in components) {
            entity.addComponent(component, false);
        }
        for(component in components) {
            component.init();
        }
        entities.push(entity);
    }

    public function update(delta: Float) {
        var targetDelta: Float = 1/60;
        var deltaMult = Math.min(delta/targetDelta, 3);
        for(entity in entities) {
            entity.update(deltaMult);
        }
    }

    public function resetScene() {
        if(scene != null) {
            scene.dispose();
        }
        
        scene = new h2d.Scene();
        camera = scene.camera;

        for(entity in entities) {
            entity.destroy();
        }
    }
}