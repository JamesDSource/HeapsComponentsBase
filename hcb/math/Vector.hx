package hcb.math;

import VectorMath;

class Vector {
    public static inline function angleToVec2(degrees: Float, magnitude: Float): Vec2 {
        var radi: Float = hxd.Math.degToRad(degrees);
        return vec2(Math.cos(radi), Math.sin(radi))*magnitude;
    }

    public static inline function getAngle(vector: Vec2): Float {
        return hxd.Math.radToDeg(Math.atan2(vector.y, vector.x));
    }

    public extern overload static inline function cross(a: Vec2, b: Vec2): Float { 
        return a.x*b.y - a.y*b.x;
    }

    public extern overload static inline function cross(a: Vec2, b: Float): Vec2 {
        return vec2(b*a.y, -b*a.x);
    }

    public extern overload static inline function cross(a: Float, b: Vec2): Vec2 {
        return vec2(-a*b.y, a*b.x);
    }
}