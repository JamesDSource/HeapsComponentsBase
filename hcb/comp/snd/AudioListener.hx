package hcb.comp.snd;

import hcb.Project.PauseMode;

class AudioListener extends  Component {
    
    private var autoEnable: Bool;
    private var listener: h2d.Object;
    
    public function new(name: String, autoEnable: Bool) {
        super(name);

        this.autoEnable = autoEnable;
        listener = new h2d.Object();
    }
    
    public override function init() {
        if(autoEnable) {
            setActive();
        }
    }

    public override function update(delta: Float) {
        var transform: Transform2D = cast parentEntity.getSingleComponentOfType(Transform2D);
        if(transform != null) {
            listener.x = transform.position.x;
            listener.y = transform.position.y;
        }
    }

    public function setActive() {
        parentEntity.project.listenerFollow = listener;
    }
}