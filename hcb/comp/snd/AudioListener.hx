package hcb.comp.snd;

import hcb.Project.PauseMode;

class AudioListener implements Component {
    public var parentEntity: Entity;
    public var updateable: Bool = true;
    public var name: String;
    public var pauseMode: PauseMode = PauseMode.idle;
    
    private var autoEnable: Bool;
    private var listener: h2d.Object;
    
    public function new(name: String, autoEnable: Bool) {
        this.autoEnable = autoEnable;
        this.name = name;
        listener = new h2d.Object();
    }
    
    public function init() {
        if(autoEnable) {
            setActive();
        }
    }

    public function update(delta: Float) {
        var transform: Transform2D = cast parentEntity.getSingleComponentOfType(Transform2D);
        if(transform != null) {
            listener.x = transform.position.x;
            listener.y = transform.position.y;
        }
    }

    public function onDestroy() {}

    public function setActive() {
        parentEntity.project.listenerFollow = listener;
    }
}