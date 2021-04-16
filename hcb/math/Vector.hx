package hcb.math;

import VectorMath;

class Vector {
    public static inline function vec2Angle(degrees: Float, magnitude: Float): Vec2 {
        var radi: Float = hxd.Math.degToRad(degrees);
        return vec2(Math.cos(radi), Math.sin(radi))*magnitude;
    }

    public static inline function getAngle(vector: Vec2): Float {
        return hxd.Math.radToDeg(Math.atan2(vector.y, vector.x));
    }
}