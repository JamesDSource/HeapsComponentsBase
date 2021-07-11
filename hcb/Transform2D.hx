package hcb;

import VectorMath;
using hcb.math.Vector; 

class Transform2D {
    public var parent(default, set): Transform2D = null;
    @:allow(hcb.Transform2D) 
    private var children: Array<Transform2D> = [];
    
    private var position: Vec2 = vec2(0, 0);
    private var rotation: Float = 0;
    private var scale: Vec2 = vec2(1, 1);

    public var positionSnap(default, set): Bool = true;
    // ^ Makes sure that the position remains an integer value
    private var positionRemainder: Vec2 = vec2(0, 0);

    private inline function set_parent(parent: Transform2D): Transform2D {
        if(this.parent == parent)
            return parent;

        var treeIteration: Transform2D = parent;
        while(true) {
            if(treeIteration == null)
                break;
            else if(treeIteration == this)
                throw "Cannot have Transform2D parent itself";

            treeIteration = parent.parent;
        }
        
        if(this.parent != null)
            this.parent.children.remove(this);

        if(parent != null)
            parent.children.push(this);

        return this.parent = parent;
    }

    private inline function set_positionSnap(positionSnap: Bool): Bool {
        if(this.positionSnap != positionSnap) {
            this.positionSnap = positionSnap;

            if(positionSnap)
                setPosition(position.x, position.y);
                // ^ Calling this will reset the remainder to whatever the current position is 
            else {
                translate(positionRemainder);
                positionRemainder.x = positionRemainder.y = 0;
            }
        }
        return positionSnap;
    }

    public function new(x: Float = 0., y: Float = 0., rotation: Float = 0., scaleX: Float = 1., scaleY: Float = 1., ?parent: Transform2D) {
        this.parent = parent;
        set(x, y, rotation, scaleX, scaleY);
    }

    public overload inline extern function set(position: Vec2, rotation: Float, scale: Vec2) {
        setPosition(position.x, position.y);
        setRotationRad(rotation);
        setScale(scale);
    }

    public overload inline extern function set(px: Float, py: Float, rotation: Float, sx: Float, sy: Float) {
        setPosition(px, py);
        setRotationRad(rotation);
        setScale(sx, sy);
    }

    public inline function model(transform: Transform2D) {
        set(transform.getPosition(true), transform.getRotationRad(true), transform.getScale(true));
    }

    // & Position functions
    public inline function translate(offset: Vec2) {
        if(Math.abs(offset.x) + Math.abs(offset.y) < hxd.Math.EPSILON)
            return;

        position += offset;
        if(positionSnap) {
            position += positionRemainder;
            positionRemainder = position - position.floor();
            position -= positionRemainder;
        }
        callOnTranslated();
    }
    
    public overload inline extern function setPosition(position: Vec2) {
        setPosition(position.x, position.y);
    }

    public overload inline extern function setPosition(x: Float, y: Float, resetRemainder: Bool = true) {
        if(positionSnap) {
            if(resetRemainder)
                positionRemainder = vec2(x - Math.ffloor(x), y - Math.ffloor(y));

            x = Math.ffloor(x);
            y = Math.ffloor(y);
        }
        
        if(Math.abs(position.x - x) < hxd.Math.EPSILON && Math.abs(position.y - y) < hxd.Math.EPSILON)
            return;

        this.position = vec2(x, y);
        callOnTranslated();
    }

    public inline function getPosition(local: Bool = false): Vec2 {
        return local || parent == null ? position.clone() : position + parent.getPosition(false);
    }

    // & Rotation functions
    public inline function rotateDeg(rotation: Float) {
        if(Math.abs(rotation) < hxd.Math.EPSILON)
            return;

        this.rotation += hxd.Math.degToRad(rotation);
        callOnRotated();
    }

    public inline function rotateRad(rotation: Float) {
        if(Math.abs(rotation) < hxd.Math.EPSILON)
            return;

        this.rotation += rotation;
        callOnRotated();
    }
    
    public inline function setRotationDeg(rotation: Float) {
        if(Math.abs(hxd.Math.radToDeg(this.rotation) - rotation) < hxd.Math.EPSILON)
            return;

        this.rotation = hxd.Math.degToRad(rotation);
        callOnRotated();
    }

    public inline function setRotationRad(rotation: Float) {
        if(Math.abs(this.rotation - rotation) < hxd.Math.EPSILON)
            return;

        this.rotation = rotation;
        callOnRotated();
    }

    public inline function getRotationDeg(local: Bool = false): Float {
        return local || parent == null ? hxd.Math.radToDeg(rotation) : hxd.Math.radToDeg(rotation + parent.getRotationRad(false));
    }

    public inline function getRotationRad(local: Bool = false): Float {
        return local || parent == null ? rotation : rotation + parent.getRotationRad(false);
    }

    public inline function getDirection(local: Bool = false): Vec2 {
        var d = vec2(0, 0);
        d.setAngle(getRotationRad(local), 1);
        return d;
    }

    // & Scale functions
    public overload inline extern function scaleFactor(scale: Vec2) {
        if(Math.abs(scale.x - 1) < hxd.Math.EPSILON && Math.abs(scale.y - 1) < hxd.Math.EPSILON)
            return;

        this.scale *= scale;
        callOnScaled();
    }

    public overload inline extern function scaleFactor(x: Float, y: Float) {
        if(Math.abs(x - 1) < hxd.Math.EPSILON && Math.abs(y - 1) < hxd.Math.EPSILON)
            return;

        scale.x *= x;
        scale.y *= y;
        callOnScaled();
    }

    public overload inline extern function setScale(scale: Vec2) {
        if(Math.abs(this.scale.x - scale.x) < hxd.Math.EPSILON && Math.abs(this.scale.y - scale.y) < hxd.Math.EPSILON)
            return;
        
        this.scale = scale.clone();
        callOnScaled();
    } 
    
    public overload inline extern function setScale(x: Float, y: Float) {
        if(Math.abs(scale.x - x) < hxd.Math.EPSILON && Math.abs(scale.y - y) < hxd.Math.EPSILON)
            return;

        scale.x = x;
        scale.y = y;
        callOnScaled();
    } 

    public inline function getScale(local: Bool = false) {
        return local || parent == null ? scale.clone() : scale*parent.getScale(false);
    }

    // & Events
    public dynamic function onTranslated(position: Vec2) {}
    public dynamic function onRotated(rotation: Float) {}
    public dynamic function onScaled(scale: Vec2) {}

    private inline function callOnTranslated() {
        onTranslated(getPosition(false));

        for(child in children)
            child.callOnTranslated();
    }

    private inline function callOnRotated() {
        onRotated(getRotationRad(false));

        for(child in children)
            child.callOnRotated();
    }

    private inline function callOnScaled() {
        onScaled(getScale(false));

        for(child in children)
            child.callOnScaled();
    }
}