package hcb;

class Timer {
    public var name: String;
    public var stopOnPause: Bool;

    public var timeRemaining: Float = 0;
    public var timeMultiplier: Float = 1;
    public var initialTime: Float = 0;
    public var callBack: (String) -> Void;
    public var onTick: (Float) -> Void = null;

    public var active: Bool = true;
    
    public function new(name: String, initialTime: Float, callBack: (String) -> Void, stopOnPause: Bool = true) {
        this.name = name;
        this.initialTime = initialTime;
        timeRemaining = initialTime;
        this.callBack = callBack;
        this.stopOnPause = stopOnPause;
    }

    public function countDown(dt: Float, paused: Bool = false) {
        if(active && timeRemaining > 0 && (!paused || !stopOnPause)) {
            timeRemaining -= dt*timeMultiplier;
            if(timeRemaining <= 0) {
                timeRemaining = 0;
                callBack(name);
            }

            if(onTick != null)
                onTick(timeRemaining);
        }
    }

    // & Resets time remaining to what it was initially set as
    public function reset() {
        timeRemaining = initialTime;
    }
}