package base.math;

class Vector2 {
    public var x: Float;
    public var y: Float;

    public function new(x: Float = 0, y: Float = 0) {
        this.x = x;
        this.y = y;
    }

    public function getLength(): Float {
        var squareX = Math.pow(Math.abs(x), 2.0);
        var squareY = Math.pow(Math.abs(y), 2.0);

        return Math.sqrt(squareX + squareY);
    }

    public function normalized(): Vector2 {
        var length = getLength();

        // * Keeping the length 0 if it is
        if(length > 0) {
            var normX = x/length;
            var normY = y/length;
            return new Vector2(normX, normY);
        }
        else {
            return new Vector2();
        }    
    }

    public function getDotProduct(vector2: Vector2): Float {
        return x*vector2.x + y*vector2.y;
    }

    public function distanceTo(vector2: Vector2): Float {
        var difference = subtract(vector2);
        return difference.getLength();
    }

    public function clone(): Vector2 {
        return new Vector2(x, y);
    }

    public function angleTo(vector2: Vector2): Float {
        var transformationVector: Vector2 = vector2.subtract(this);
        return transformationVector.getAngle();
    }

    public function getAngle(): Float {
        return Math.atan2(y, x);
    }

    // & Vector math functions
    public function add(vector2: Vector2): Vector2 {
        return new Vector2(x + vector2.x, y + vector2.y);
    }

    public function addMutate(vector2: Vector2): Void {
        x += vector2.x;
        y += vector2.y;
    }

    public function subtract(vector2: Vector2): Vector2 {
        return new Vector2(x - vector2.x, y - vector2.y);
    }

    public function subtractMutate(vector2: Vector2): Void {
        x -= vector2.x;
        y -= vector2.y;
    }

    public function mult(vector2: Vector2): Vector2 {
        return new Vector2(x*vector2.x, y*vector2.y);
    }

    public function multMutate(vector2: Vector2): Void {
        x *= vector2.x;
        y *= vector2.y;
    }

    public function div(vector2: Vector2): Vector2 {
        return new Vector2(x/vector2.x, y/vector2.y);
    }

    public function divMutate(vector2: Vector2): Void {
        x /= vector2.x;
        y /= vector2.y;
    }

    // & Float math functions
    public function addF(float: Float): Vector2 {
        return new Vector2(x + float, y + float);
    }

    public function addFMutate(float: Float): Void {
        x += float;
        y += float;
    }
    
    public function subtractF(float: Float): Vector2 {
        return new Vector2(x - float, y - float);
    }

    public function subtractFMutate(float: Float): Void {
        x -= float;
        y -= float;
    }

    public function multF(float: Float): Vector2 {
        return new Vector2(x*float, y*float);
    }

    public function multFMutate(float: Float): Void {
        x *= float;
        y *= float;
    }

    public function divF(float: Float): Vector2 {
        return new Vector2(x/float, y/float);
    }

    public function divFMutate(float: Float): Void {
        x /= float;
        y /= float;
    }
}