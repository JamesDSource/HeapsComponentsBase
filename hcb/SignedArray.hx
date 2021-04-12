package hcb;

class SignedArray<T> {
    private var positives: Array<T> = [];
    private var negatives: Array<T> = [];

    public function new() {}

    public function get(i: Int): T {
        if(i >= 0) {
            return positives[i];
        }
        else {
            return negatives[i * -1];
        }
    }

    public function set(i: Int, value: T) {
        if(i >= 0) {
            positives[i] = value;
        }
        else {
            negatives[i * -1] = value;
        }
    }
}