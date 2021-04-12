package hcb;

class SignedArray<T> {
    private var positives: Array<T> = [];
    private var negatives: Array<T> = [];

    public var length(get, null): Int;
    public var fullArray(get, null): Array<T>;

    private inline function get_length(): Int {
        return positives.length + cast(Math.max(0, negatives.length-1), Int);
    }

    private inline function get_fullArray(): Array<T> {
        var returnArray: Array<T>;

        if(negatives.length > 1) {
            returnArray = negatives.copy();
            returnArray.reverse();
            returnArray.pop();
            
            for(positive in positives) {
                returnArray.push(positive);
            }
        }
        else {
            returnArray = positives.copy();
        }

        return returnArray;
    }

    public function new() {}

    public inline function get(i: Int): T {
        if(i >= 0) {
            return positives[i];
        }
        else {
            return negatives[i * -1];
        }
    }

    public inline function set(i: Int, value: T) {
        if(i >= 0) {
            positives[i] = value;
        }
        else {
            negatives[i * -1] = value;
        }
    }
}