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

    public static inline function color(): Int {
        var red: Int = randomRange(0, 256);
        var green: Int = randomRange(0, 256);
        var blue: Int = randomRange(0, 256);

        return dn.Color.rgbToInt({r: red, g: green, b: blue});
    }
}