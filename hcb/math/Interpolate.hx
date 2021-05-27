package hcb.math;

import VectorMath;

class Interpolate {
    // & Interpolates between two floats
    public overload extern static inline function interpolateBetween(start: Float, ideal:Float, offset: Float): Float {
        if(Math.abs(ideal - start) <= Math.abs(offset)) {
            return ideal;
        }
        else if(start < ideal) {
            return start + Math.abs(offset);
        }
        else {
            return start - Math.abs(offset);
        }
    }

    // & Interpolates between two vectirs
    public overload extern static inline function interpolateBetween(start: Vec2, ideal: Vec2, offset: Float): Vec2 {
        var directionVector: Vec2 = (ideal - start).normalize();
        return vec2(interpolateBetween(start.x, ideal.x, directionVector.x*offset), interpolateBetween(start.y, ideal.y, directionVector.y*offset));
    }
}