package hcb.math;

import VectorMath;

class Vector {
    public overload static inline extern function set(a: Vec2, b: Vec2) {
        a.x = b.x;
        a.y = b.y;
    }

    public overload static inline extern function set(a: Vec3, b: Vec3) {
        a.x = b.x;
        a.y = b.y;
        a.z = b.z;
    }

    public static function setAngle(v: Vec2, radi: Float, ?magnitude: Null<Float>) {
        if(magnitude == null)
            magnitude = v.length();

        v.x = Math.cos(radi)*magnitude;
        v.y = Math.sin(radi)*magnitude;
    }

    public static inline function getAngle(vector: Vec2): Float {
        return Math.atan2(vector.y, vector.x);
    }

    public static inline function cross(a: Vec2, b: Vec2): Float { 
        return a.x*b.y - a.y*b.x;
    }

    public static inline function crossLeft(v: Vec2, scale: Float = 1.): Vec2 {
        return vec2(scale*v.y, -scale*v.x);
    }

    public static inline function crossRight(v: Vec2, scale: Float = 1.): Vec2 {
        return vec2(-scale*v.y, scale*v.x);
    }

    public overload static inline extern function tripleProduct(a: Vec2, b: Vec2, c: Vec2): Vec2 {
        return b*(c*a) - a*(c*b);
    }

    public overload static inline extern function tripleProduct(a: Vec3, b: Vec3, c: Vec3): Vec3 {
        return a.cross(b).cross(c);
    }

    public static inline function approach(a: Vec2, b: Vec2, scaler: Float): Vec2 {
        scaler = Math.abs(scaler);
        var r = a.clone();

        r.x = hcb.math.TweenManager.approach(r.x, b.x, scaler);
        r.y = hcb.math.TweenManager.approach(r.y, b.y, scaler);
        return r;
    }

    public overload static inline extern function distanceSquared(a: Vec2, b: Vec2): Float {
        return (b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y);
    }

    public overload static inline extern function distanceSquared(a: Vec3, b: Vec3): Float {
        return (b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y) + (b.z - a.z)*(b.z - a.z);
    }

    public overload static inline extern function lengthSquared(v: Vec2): Float {
        return v.x*v.x + v.y*v.y;
    }

    public overload static inline extern function lengthSquared(v: Vec3) {
        return v.x*v.x + v.y*v.y + v.z*v.z;
    }
}