package hcb.comp;

class Camera extends Component {
    private var follow: h2d.Object = new h2d.Object();

    private var autoEnable: Bool;

    public function new(name: String, autoEnable: Bool) {
        super(name);
        this.autoEnable = autoEnable;
    }

    public override function init() {
        if(autoEnable) {
            setActiveCamera();
        }
    }

    public override function update(delta: Float): Void {
        var transform: Transform2D = cast parentEntity.getSingleComponentOfType(Transform2D);
        if(transform != null) {
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
            parentEntity.project.cameraFollow = follow;
        }
    }
}