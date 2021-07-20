package hcb.comp.anim;

import h2d.Tile;
import hcb.Origin;
import VectorMath;

class Anim extends h2d.Anim {
    public var stop: Bool = false;

    public var originPoint(default, set): OriginPoint = OriginPoint.TopLeft;
    public var originOffsetX(default, set): Float = 0;
    public var originOffsetY(default, set): Float = 0;

    private var onFrameEventListeners: Map<Int, Array<() -> Void>> = [];

    private function set_originPoint(originPoint: OriginPoint): OriginPoint {
        if(this.originPoint != originPoint) {
            this.originPoint = originPoint;
            setOrigin();
        }
        return originPoint;
    }

    private function set_originOffsetX(originOffsetX: Float): Float {
        if(this.originOffsetX != originOffsetX) {
            this.originOffsetX = originOffsetX;
            setOrigin();
        }
        return originOffsetX;
    }

    private function set_originOffsetY(originOffsetY: Float): Float {
        if(this.originOffsetY != originOffsetY) {
            this.originOffsetY = originOffsetY;
            setOrigin();
        }
        return originOffsetY;
    }

    @:allow(hcb.comp.anim.Animation)
    private function new(strip: Tile, frames: Int, speed: Float, originPoint: OriginPoint, originOffsetX: Float, originOffsetY: Float) {
        var animFrames: Array<Tile> = strip.split(frames);
        super(animFrames, speed);
        this.originPoint = originPoint;
        this.originOffsetX = originOffsetX;
        this.originOffsetY = originOffsetY;
    }

    private function setOrigin() {
        for(animFrame in frames) {
            var w = animFrame.width;
            var h = animFrame.height;

            // * Setting the origin
            var offset: Vec2 = Origin.getOriginOffset(originPoint, vec2(w, h));
            animFrame.dx = offset.x + originOffsetX;
            animFrame.dy = offset.y + originOffsetY;
        }
    }

    // & On frame event functions
    public function onFrameEventSubscribe(frame: Int, callBack: () -> Void) {
        if(onFrameEventListeners.exists(frame))
            onFrameEventListeners[frame].push(callBack);
        else 
            onFrameEventListeners[frame] = [callBack];
    }

    public function onFrameEventRemove(frame: Int, callBack: () -> Void): Bool {
        if(onFrameEventListeners.exists(frame)) {
            var result: Bool = onFrameEventListeners[frame].remove(callBack);
            
            if(onFrameEventListeners[frame].length == 0)
                onFrameEventListeners.remove(frame);
            
            return result;
        }
        
        return false;
    }

    @:allow(hcb.comp.anim.Animation)
    private function onFrameEventCall(frame: Int) {
        if(onFrameEventListeners.exists(frame)) {
            for(listener in onFrameEventListeners[frame])
                listener();
        }
    }
}

@:forward(  // * hcb.Anim
            stop, originPoint, originOffsetX, originOffsetY, 
            onFrameEventSubscribe, onFrameEventRemove,
            // * h2d.Anim
            currentFrame, speed, loop, 
            fading, getFrame, onAnimEnd,
            // * Drawable
            color, smooth, tileWrap,
            colorKey, colorMatrix,
            colorAdd, adjustColor,
            getDebugShaderCode, getShader,
            getShaders, addShader, removeShader,
            // * Object
            parent, numChildren, x, y, scaleX, scaleY, rotation, 
            visible, alpha, filter, blendMode, #if domkit dom, #end
            getBounds, getSize, getAbsPos, contains,
            find, findAll, getObjectsCount, localToGlobal,
            globalToLocal, getScene, addChild, addChildAt,
            removeChild, removeChildren, remove, removeChildren,
            drawTo, drawToTextures, move, setPosition,
            rotate, scale, setScale, getChildAt, getChildIndex,
            getObjectByName, iterator
)
abstract Animation(Anim) to h2d.Anim {
    public function new(strip: Tile, frames: Int, speed: Float = 15, originPoint: OriginPoint = TopLeft, originOffsetX: Float = 0, originOffsetY: Float = 0) {
        this = new Anim(strip, frames, speed, originPoint, originOffsetX, originOffsetY);
        this.pause = true;
    }

    @:arrayAccess
    public inline function get(i: Int): Tile {
        return this.frames[i];
    }

    @:access(h2d.Anim.curFrame)
    public function step(dt: Float) {
        
        var prev = this.curFrame;
		if (!this.stop)
			this.curFrame += this.speed * dt;
		
        if(this.speed == 0)
            return;
        else if(this.speed > 0 && this.curFrame < this.frames.length) {
			if(Std.int(prev) != Std.int(this.curFrame))
                this.onFrameEventCall(Std.int(this.curFrame));
            return;
        }
        else if(this.speed < 0 && this.curFrame > 0) {
            if(Std.int(prev) != Std.int(this.curFrame))
                this.onFrameEventCall(Std.int(this.curFrame));
            return;
        }
		
        // * When the animation ends
        if(this.loop) {
			if(this.frames.length == 0)
				this.curFrame = 0;
			else if(this.speed > 0)
				this.curFrame %= this.frames.length;
            else
                this.curFrame += this.frames.length;
            this.onFrameEventCall(Std.int(this.curFrame));
			this.onAnimEnd();
		} 
        else {
			this.curFrame = this.speed > 0  ? this.frames.length : 0;
            if(this.curFrame != prev) this.onAnimEnd();
		}
    }
}