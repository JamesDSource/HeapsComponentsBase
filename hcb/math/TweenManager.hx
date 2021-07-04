package hcb.math;

enum Ease {
    Linear;
    EaseInSine;
    EaseOutSine;
    EaseInOutSine;
    EaseInQuad;
    EaseOutQuad;
    EaseInOutQuad;
    EaseInCubic;
    EaseOutCubic;
    EaseInOutCubic;
    EaseInQuart;
    EaseOutQuart;
    EaseInOutQuart;
    EaseInQuint;
    EaseOutQuint;
    EaseInOutQuint;
    EaseInExpo;
    EaseOutExpo;
    EaseInOutExpo;
    EaseInCirc;
    EaseOutCirc;
    EaseInOutCirc;
    EaseInBack;
    EaseOutBack;
    EaseInOutBack;
    EaseInElastic;
    EaseOutElastic;
    EaseInOutElastic;
    EaseInBounce;
    EaseOutBounce;
    EaseInOutBounce;
    Custom(ease: (Float, Float, Float) -> Float);
}

typedef Tween = {
    > hcb.Pause.Pauseable,
    active: Bool,
    delay: Float,
    delayLeft: Float,
    t: Float,
    t1: Float,
    x0: Float,
    x1: Float,
    o: Dynamic,
    variable: String,
    ease: (Float, Float, Float) -> Float,
    ?onEnd: () -> Void
}

class TweenManager {
    private var tweens: Array<Tween> = [];
    private var objTweens: Map<String, Array<Tween>> = new Map<String, Array<Tween>>();

    public function new() {}

    public function step(delta: Float, paused: Bool) {
        for(tween in tweens.copy()) {
            if(!tween.active || (paused && !hcb.Pause.updateOnPause(tween)))
                continue;

            if(tween.delayLeft > 0) {
                tween.delayLeft -= delta;
                continue;
            }

            tween.t += delta;
            var percent = hxd.Math.clamp(tween.t/tween.t1, 0, 1);
            var newValue = tween.ease(percent, tween.x0, tween.x1);
            
            if(Std.isOfType(Reflect.getProperty(tween.o, tween.variable), Int))
                Reflect.setProperty(tween.o, tween.variable, Std.int(newValue));
            else
                Reflect.setProperty(tween.o, tween.variable, newValue);

            if(percent == 1) {
                if(tween.onEnd != null)
                    tween.onEnd();

                removeTween(tween);
            }
        }
    }

    public function addTween(obj: Dynamic, variable: String, target: Float, ease: Ease, t: Float, ?delay: Float = 0., ?pauseState: hcb.Pause.PauseState = Idle, ?onEnd: () -> Void): TweenInstance {
        if(objTweens.exists(variable)) {
            // * Check if this overrides a ongoing tween
            for(tween in objTweens[variable]) {
                if(tween.o != obj || tween.x1 == target)
                    continue;

                objTweens[variable].remove(tween);
                tweens.remove(tween);
                break;
            }
        }
        else
            objTweens[variable] = new Array<Tween>();

        var prop: Dynamic = Reflect.getProperty(obj, variable);
        var tween: Tween = {
            pauseState: pauseState,
            active: true,
            delay: delay,
            delayLeft: delay,
            t: 0,
            t1: t,
            x0: 0,
            x1: target,
            o: obj,
            variable: variable,
            ease: null,
            onEnd: onEnd
        }

        // * Getting the initial value
        if(!Std.isOfType(prop, Float) && !Std.isOfType(prop, Int))
            throw "Invalid tween type. Please use a Float or Int";
        tween.x0 = cast(prop, Float);

        // * Getting the ease function
        switch(ease) {
            case Linear:
                tween.ease = easeLinear;
            case EaseInSine:
                tween.ease = easeInSine;
            case EaseOutSine:
                tween.ease = easeOutSine;
            case EaseInOutSine:
                tween.ease = easeInOutSine;
            case EaseInQuad:
                tween.ease = easeInQuad;
            case EaseOutQuad:
                tween.ease = easeOutQuad;
            case EaseInOutQuad:
                tween.ease = easeInOutQuad;
            case EaseInCubic:
                tween.ease = easeInCubic;
            case EaseOutCubic:
                tween.ease = easeOutCubic;
            case EaseInOutCubic:
                tween.ease = easeInOutCubic;
            case EaseInQuart:
                tween.ease = easeInQuart;
            case EaseOutQuart:
                tween.ease = easeOutQuart;
            case EaseInOutQuart:
                tween.ease = easeInOutQuart;
            case EaseInQuint:
                tween.ease = easeInQuint;
            case EaseOutQuint:
                tween.ease = easeOutQuint;
            case EaseInOutQuint:
                tween.ease = easeInOutQuint;
            case EaseInExpo:
                tween.ease = easeInExpo;
            case EaseOutExpo:
                tween.ease = easeOutExpo;
            case EaseInOutExpo:
                tween.ease = easeInOutExpo;
            case EaseInCirc:
                tween.ease = easeInCirc;
            case EaseOutCirc:
                tween.ease = easeOutCirc;
            case EaseInOutCirc:
                tween.ease = easeInOutCirc;
            case EaseInBack:
                tween.ease = easeInBack;
            case EaseOutBack:
                tween.ease = easeOutBack;
            case EaseInOutBack:
                tween.ease = easeInOutBack;
            case EaseInElastic:
                tween.ease = easeInElastic;
            case EaseOutElastic:
                tween.ease = easeOutElastic;
            case EaseInOutElastic:
                tween.ease = easeInOutElastic;
            case EaseInBounce:
                tween.ease = easeInBounce;
            case EaseOutBounce:
                tween.ease = easeOutBounce;
            case EaseInOutBounce:
                tween.ease = easeInOutBounce;
            case Custom(ease):
                tween.ease = ease;
        }

        objTweens[variable].push(tween);
        tweens.push(tween);
        return new TweenInstance(tween, this);
    }

    @:allow(hcb.math.TweenInstance)
    private function removeTween(tween: Tween) {
        if(objTweens.exists(tween.variable)) {
            objTweens[tween.variable].remove(tween);
            if(objTweens[tween.variable].length == 0)
                objTweens.remove(tween.variable);
        }
        return tweens.remove(tween);
    }

    // &  Linear ease
    public static inline function easeLinear(t: Float, initial: Float, target: Float): Float {     
        return initial + (target - initial)*t;
    }

    // & Ease sine functions
    public static inline function easeInSine(t: Float, initial: Float, target: Float): Float {     
        return initial + (1 - Math.cos((t*Math.PI)/2))*(target - initial);
    }

    public static inline function easeOutSine(t: Float, initial: Float, target: Float): Float {     
        return initial + Math.sin((t*Math.PI)/2)*(target - initial);
    }

    public static inline function easeInOutSine(t: Float, initial: Float, target: Float): Float {     
        return initial + (-(Math.cos(Math.PI*t) - 1)/2)*(target - initial);
    }

    // & Ease quad functions
    public static inline function easeInQuad(t: Float, initial: Float, target: Float): Float {     
        return initial + Math.pow(t, 2)*(target - initial);
    }

    public static inline function easeOutQuad(t: Float, initial: Float, target: Float): Float {     
        return initial + (1 - Math.pow(1 - t, 2))*(target - initial);
    }

    public static inline function easeInOutQuad(t: Float, initial: Float, target: Float): Float {     
        return initial + (t < 0.5 ? 2*t*t : 1 - Math.pow(-2*t + 2, 2)/2)*(target - initial);
    }

    // & Ease cubic functions
    public static inline function easeInCubic(t: Float, initial: Float, target: Float): Float {
        return initial + Math.pow(t, 3)*(target - initial);
    }

    public static inline function easeOutCubic(t: Float, initial: Float, target: Float): Float {
        return initial + (1 - Math.pow(1 - t, 3))*(target - initial);
    }

    public static inline function easeInOutCubic(t: Float, initial: Float, target: Float): Float {
        return initial + (t < 0.5 ? 4*Math.pow(t, 3) : 1 - Math.pow(-2*t + 2, 3)/2)*(target - initial);
    }

    // & Ease quart functions
    public static inline function easeInQuart(t: Float, initial: Float, target: Float): Float {
        return initial + Math.pow(t, 4)*(target - initial);
    }

    public static inline function easeOutQuart(t: Float, initial: Float, target: Float): Float {
        return initial + (1 - Math.pow(1 - t, 4))*(target - initial);
    }

    public static inline function easeInOutQuart(t: Float, initial: Float, target: Float): Float {
        return initial + (t < 0.5 ? 8*Math.pow(t , 4) : 1 - Math.pow(-2*t + 2, 4)/2)*(target - initial);
    }

    // & Ease quint functions
    public static inline function easeInQuint(t: Float, initial: Float, target: Float): Float {
        return initial + Math.pow(t, 5)*(target - initial);
    }

    public static inline function easeOutQuint(t: Float, initial: Float, target: Float): Float {
        return initial + (1 - Math.pow(1 - t, 5))*(target - initial);
    }

    public static inline function easeInOutQuint(t: Float, initial: Float, target: Float): Float {
        return initial + (t < 0.5 ? 16*Math.pow(t, 5) : 1 - Math.pow(-2*t + 2, 5)/2)*(target - initial);
    }

    // & Ease expo functions
    public static inline function easeInExpo(t: Float, initial: Float, target: Float): Float {
        return initial + (t == 0 ? 0 : Math.pow(2, 10*t - 10))*(target - initial);
    }

    public static inline function easeOutExpo(t: Float, initial: Float, target: Float): Float {
        return initial + (t == 1 ? 1 : 1 - Math.pow(2, -10*t))*(target - initial);
    }

    public static inline function easeInOutExpo(t: Float, initial: Float, target: Float): Float {
        if(t == 0)
            return initial;
        if(t == 1)
            return target;
        return initial + (t < 0.5 ? Math.pow(2, 20*t - 10)/2 : (2 - Math.pow(2, -20*t + 10))/2)*(target - initial);
    }

    // & Ease circ functions
    public static inline function easeInCirc(t: Float, initial: Float, target: Float): Float {
        return initial + (1 - Math.sqrt(1 - Math.pow(t, 2)))*(target - initial);
    }

    public static inline function easeOutCirc(t: Float, initial: Float, target: Float): Float {
        return initial + (Math.sqrt(1 - Math.pow(t - 1, 2)))*(target - initial);
    }

    public static inline function easeInOutCirc(t: Float, initial: Float, target: Float): Float {
        return initial + (t < 0.5   ? (1 - Math.sqrt(1 - Math.pow(2*t, 2)))/2 
                                    : (Math.sqrt(1 - Math.pow(-2*t + 2, 2)) + 1)/2)*(target - initial);
    }

    // & Ease back functions
    public static inline function easeInBack(t: Float, initial: Float, target: Float): Float {
        final C1 = 1.70158;
        final C3 = C1 + 1;

        return initial + (C3*Math.pow(t, 3) - C1*t*t)*(target - initial);
    }

    public static inline function easeOutBack(t: Float, initial: Float, target: Float): Float {
        final C1 = 1.70158;
        final C3 = C1 + 1;

        return initial + (1 + C3*Math.pow(t - 1, 3) + C1*Math.pow(t - 1, 2))*(target - initial);
    }

    public static inline function easeInOutBack(t: Float, initial: Float, target: Float): Float {
        final C1 = 1.70158;
        final C2 = C1*1.525;

        return initial + (t < 0.5   ? (Math.pow(2*t, 2)*((C2 + 1)*2*t - C2))/2
                                    : (Math.pow(2*t - 2, 2)*((C2 + 1)*(t*2 - 2) + C2) + 2)/2)*(target - initial);
    }

    // & Ease elastic functions
    public static inline function easeInElastic(t: Float, initial: Float, target: Float): Float {
        if(t == 0)
            return initial;
        if(t == 1)
            return target;

        final C4 = (2*Math.PI)/3;
        return initial - Math.pow(2, 10*t - 10)*Math.sin((t*10 - 10.75)*C4)*(target - initial);
    }

    public static inline function easeOutElastic(t: Float, initial: Float, target: Float): Float {
        if(t == 0)
            return initial;
        if(t == 1)
            return target;

        final C4 = (2*Math.PI)/3;
        return initial + (Math.pow(2, -10*t)*Math.sin((t*10 - .75)*C4) + 1)*(target - initial);
    }

    public static inline function easeInOutElastic(t: Float, initial: Float, target: Float): Float {
        if(t == 0)
            return initial;
        if(t == 1)
            return target;

        final C5 = (2*Math.PI)/4.5;
        return initial + (t < 0.5   ? -(Math.pow(2, 20*t - 10)*Math.sin((20*t - 11.125)*C5))/2
                                    : (Math.pow(2, -20*t + 10)*Math.sin((20*t - 11.125)*C5))/2 + 1)*(target - initial);
    }

    // & Ease bounce functions
    public static inline function easeInBounce(t: Float, initial: Float, target: Float): Float {
        return initial + (1 - bounceOut(1 - t))*(target - initial);
    }

    public static inline function easeOutBounce(t: Float, initial: Float, target: Float): Float {
        return initial + bounceOut(t)*(target - initial);
    }

    public static inline function easeInOutBounce(t: Float, initial: Float, target: Float): Float {
        return initial + (t < 0.5   ? (1 - bounceOut(1 - 2*t))/2 : (1 + bounceOut(2*t - 1))/2)*(target - initial);
    }

    private static function bounceOut(t: Float) {
        final N1 = 7.5625;
        final D1 = 2.75;

        if(t < 1/D1) {
            return N1*t*t;
        }
        else if(t < 2/D1) {
            return N1*(t -= 1.5/D1)*t + .75;
        }
        else if(t < 2.5/D1) {
            return N1*(t -= 2.25/D1)*t + .9375;
        }

        return N1*(t -= 2.625/D1)*t + .984375; 
    }
}

class TweenInstance {
    private var instance: Tween;
    private var manager: TweenManager;

    public var active(get, set): Bool;
    
    private function get_active(): Bool {
        return instance.active;
    }

    private function set_active(active: Bool): Bool {
        return instance.active = active;
    }

    @:allow(hcb.math.TweenManager)
    private function new(instance: Tween, manager: TweenManager) {
        this.instance = instance;
        this.manager = manager;
    }

    public function remove(): Bool {
        return manager.removeTween(instance);
    }

    public function reset() {
        instance.delayLeft = instance.delay;
        instance.t = 0;
    }
}