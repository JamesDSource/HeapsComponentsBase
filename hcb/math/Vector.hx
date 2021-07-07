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

    public static function setAngle(v: Vec2, degrees: Float, ?magnitude: Null<Float>) {
        var radi: Float = hxd.Math.degToRad(degrees);
        if(magnitude == null)
            magnitude = v.length();

        v.x = Math.cos(radi)*magnitude;
        v.y = Math.sin(radi)*magnitude;
    }

    public static inline function getAngle(vector: Vec2): Float {
        return hxd.Math.radToDeg(Math.atan2(vector.y, vector.x));
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
}