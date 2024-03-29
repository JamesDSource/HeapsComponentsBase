package hcb;

import hcb.comp.col.*;
import VectorMath;

typedef IndexGridData = { 
    indexs: Array<Int>,
    width: Int,
    height: Int,
    defaultValue: Int,
    ?cellSize: Null<Float>,
    ?position: Vec2
    
}

abstract IndexGrid(IndexGridData) to IndexGridData from IndexGridData {
    #if ldtk_haxe_api
    public static function ldtkTilesConvert(tileLayer: ldtk.Layer_Tiles): IndexGrid {
        var indexGrid = new IndexGrid(tileLayer.cWid, tileLayer.cHei);
        indexGrid.cellSize = tileLayer.gridSize;

        for(i in 0...tileLayer.cHei) {
            for(j in 0...tileLayer.cWid) {
                var hasTile = tileLayer.hasAnyTileAt(j, i);
                if(hasTile)
                    indexGrid[indexGrid.coordsToIndex(j, i)] = tileLayer.getTileStackAt(j, i)[0].tileId;
            }
        }

        return indexGrid;
    }

    public static function ldtkIntGridConvert(intGridLayer: ldtk.Layer_IntGrid): IndexGrid {
        var indexGrid = new IndexGrid(intGridLayer.cWid, intGridLayer.cHei);
        indexGrid.cellSize = intGridLayer.gridSize;

        for(i in 0...intGridLayer.cHei) {
            for(j in 0...intGridLayer.cWid) {
                var hasValue = intGridLayer.hasValue(j, i);
                if(hasValue)
                    indexGrid[indexGrid.coordsToIndex(j, i)] = intGridLayer.getInt(j, i);
            }
        }

        return indexGrid;
    }
    #end
    
    public var length(get, never): Int;
    public var width(get, never): Int;
    public var height(get, never): Int;
    public var cellSize(get, set): Null<Float>;
    public var position(get, set): Vec2;
    public var defaultValue(get, set): Int;

    private inline function get_length(): Int {
        return this.indexs.length;
    }

    private inline function get_width(): Int {
        return this.width;
    }

    private inline function get_height(): Int {
        return this.height;
    }

    private inline function get_cellSize(): Null<Float> {
        return this.cellSize;
    }

    private inline function set_cellSize(cellSize: Null<Float>): Null<Float> {
        return this.cellSize = cellSize;
    }

    private inline function get_position(): Vec2 {
        return this.position;
    }

    private inline function set_position(position: Vec2): Vec2 {
        return this.position = position;
    }

    private inline function get_defaultValue(): Int {
        return this.defaultValue;
    }

    private inline function set_defaultValue(defaultValue: Int): Int {
        return this.defaultValue = defaultValue;
    }

    public function new(width: Int, height: Int, defaultValue: Int = -1) {
        var a = new Array<Int>();
        a.resize(width*height);
        
        this = {
            width: width,
            height: height,
            indexs: a.map((i) -> defaultValue),
            defaultValue: defaultValue
        }
    }

    @:arrayAccess
    public overload inline extern function get(i: Int): Int {
        return this.indexs[i];
    }

    @:arrayAccess
    public inline function set(i: Int, v: Int) {
        this.indexs[i] = v;
    }

    public inline function copyIndexs(indexs: Array<Int>) {
        this.indexs = indexs.copy();
        
        var idealLen: Int = this.width*this.height;
        if(indexs.length > idealLen)
            indexs.resize(idealLen);
        else if(indexs.length < idealLen) {
            var oldLen: Int = indexs.length;
            indexs.resize(idealLen);
            for(i in (oldLen - 1)...idealLen)
                indexs[i] = defaultValue;
        }
    }

    public function blit(indexGrid: IndexGrid, ?position: Vec2, ?ignore: Array<Int>) {
        var startPosition: Vec2 = position != null ? position : vec2(0, 0);

        for(x in Std.int(startPosition.x)...Std.int(startPosition.x + indexGrid.width)) {
            for(y in Std.int(startPosition.y)...Std.int(startPosition.y + indexGrid.height)) {
                if(!inRange(x, y))
                    continue;

                var destIndex = coordsToIndex(x, y);
                var srcIndex = coordsToIndex(Std.int(x - startPosition.x), Std.int(y - startPosition.y));
                if(ignore != null && ignore.contains(indexGrid[srcIndex]))
                    continue;
                
                this.indexs[destIndex] = indexGrid[srcIndex];
            }
        }
    }

    public overload inline extern function coordsToIndex(x: Int, y: Int): Int {
        return x + y*this.width;
    }

    public overload inline extern function coordsToIndex(coords: Vec2): Int {
        coords = coords.floor();
        return Std.int(coords.x + coords.y*this.width);
    }

    public inline function getCoords(i: Int): Vec2 {
        return vec2(i%this.width, Math.floor(i/this.width));
    }

    public inline function inRange(x: Int, y: Int): Bool {
        return x >= 0 && x < this.width && y >= 0 && y < this.height;
    }

    public function resize(w: Int, h: Int) {
        var newIndexs: Array<Int> = [];
        newIndexs.resize(w*h);
        newIndexs = newIndexs.map((i) -> this.defaultValue);

        for(i in 0...this.indexs.length) {
            var coords = getCoords(i);
            if(coords.x >= w || coords.y >= h)
                continue;
            
            var newIndex: Int = Std.int(coords.x + coords.y*h);
            newIndexs[newIndex] = this.indexs[i];
        }

        this.width = w;
        this.height = h;
        this.indexs = newIndexs;
    }
}