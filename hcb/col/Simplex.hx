package hcb.col;

class Simplex<T> {
    private var contents: Array<T> = [];
    public var size(default, null): Int = 0;
    private var max: Int;

    public var begin(get, null): T;
    public var end(get, null): T;

    private inline function get_begin(): T {
        if(size == 0)
            return null;
        
        return contents[0];
    }

    private inline function get_end(): T {
        if(size == 0)
            return null;
        
        return contents[contents.length - 1];
    }

    public function new(dimensions: Int, ?init: Array<T>) {
        max = dimensions + 1;

        if(init != null) {
            contents = init.copy();
            if(contents.length > max)
                contents.resize(max);

            size = contents.length;
        }
    }

    public inline function get(i: Int): T {
        return contents[i];
    }

    public function push(x: T) {
        contents.insert(0, x);
        if(contents.length > max)
            contents.resize(max);

        size = Std.int(Math.min(size + 1, max));
    }

    public function remove(x: T): Bool {
        var r = contents.remove(x);
        if(r)
            size--;

        return r;
    }

    public function getContents(): Array<T> {
        return contents;
    }
}