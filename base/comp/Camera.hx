package base.comp;

class Camera implements Component {
    public var parentEntity: Entity = null;
    public var updateable: Bool = true;
    public var name: String;
    public var pauseMode = base.Project.PauseMode.idle;

    private var follow: h2d.Object = new h2d.Object();

    private var autoEnable: Bool;

    public function new(name: String, autoEnable: Bool) {
        this.name = name;
        this.autoEnable = autoEnable;
    }

    public function init() {
        if(autoEnable) {
            setActiveCamera();
        }
    }

    public function onDestroy() {
        
    }

    public function update(delta: Float): Void {
        var transforms: Array<Component> = parentEntity.getComponentsOfType(Transform2D);
        if(transforms.length > 0) {
            var transform: Transform2D = cast(transforms[0], Transform2D);
            follow.x = transform.position.x;
            follow.y = transform.position.y;
        }
        else {
            follow.x = 0;
            follow.y = 0;
        }

    }

    public function setActiveCamera(): Void {
        if(parentEntity != null) {
            parentEntity.project.camera.follow = follow;
        }
    }
}