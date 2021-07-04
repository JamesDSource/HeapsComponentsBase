package hcb.math;

import hxd.Rand;

class Random {
    public static var generator(default, null) = Rand.create();

    // & randomRange functions all have an excluded max
    public extern overload static inline function randomRange(min: Float, max: Float): Float {
        return min + generator.rand()*(max - min);
    }

    public extern overload static inline function randomRange(min: Int, max: Int): Int {
        return min + generator.random(max - min);
    }
}