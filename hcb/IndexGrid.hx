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

enum SlopeFace {
    TopLeft;
    TopRight;
    BottomLeft;
    BottomRight;
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

    // & Returns an array of Collision shapes. By default, these will be AABBs with their offsets set to their
    // & position on the grid. This can be overriden with the custom shapes map that stores functions with indexs 
    // & that take in grid position, the cell size, and outputs a collision shape to use.
    public function convertToCollisionShapes(?offset: Vec2, ?tags: Array<String>, ?customShapes: Map<Int, Vec2->Float->CollisionShape>): Array<CollisionShape> {
        var shapes: Array<CollisionShape> = [];
        for(i in 0...length) {
            // * Getting the coordinates
            var y: Int = hxd.Math.floor(i / this.width);
            var x: Int = i - y*this.width;

            // * Getting the origin point
            var org: Vec2 = vec2(x, y);
            var cellSize = this.cellSize == null ? 1 : this.cellSize;
            org *= cellSize;
            if(offset != null)
                org += offset;

            // * Getting the collision shape
            var index: Int = get(i);
            var newShape: CollisionShape = null;
            if(customShapes != null && customShapes.exists(index)) {
                newShape = customShapes[index](org, cellSize);
            }
            else if(index != -1) {
                var staticColShape = new CollisionAABB(cellSize, cellSize);
                staticColShape.transform.setPosition(this.position != null ? this.position + org : org);
                newShape = staticColShape;
            }

            if(newShape != null) {
                // * Adding tags if defined
                if(tags != null) {
                    for(tag in tags) {
                        newShape.tags.push(tag);
                    }
                }

                shapes.push(newShape);
            }
        }
        return shapes;
    }

    @:arrayAccess
    public overload inline extern function get(i: Int): Int {
        return this.indexs[i];
    }

    @:arrayAccess
    public inline function set(i: Int, v: Int) {
        this.indexs[i] = v;
    }

    public inline function coordsToIndex(x: Int, y: Int): Int {
        return x + y*this.width;
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

    public static inline function slopeBuild(slopeFace: SlopeFace, widthPercent: Float = 1.0, heightPercent: Float = 1.0, origin: Vec2, tileSize: Float): CollisionShape {
        var supportingPoint: Vec2;
        var hDir: Int = 0, vDir: Int = 0;
        switch(slopeFace) {
            case SlopeFace.TopLeft:
                supportingPoint = vec2(tileSize, tileSize);
                hDir = vDir = -1;
            case SlopeFace.TopRight:
                supportingPoint = vec2(0, tileSize);
                hDir = 1;
                vDir = -1;
            case SlopeFace.BottomLeft:
                supportingPoint = vec2(tileSize, 0);
                hDir = -1;
                vDir = 1;
            case SlopeFace.BottomRight:
                supportingPoint = vec2(0, 0);
                hDir = vDir = 1;
        }
        
        var verts: Array<Vec2> = [
            supportingPoint,
            vec2(supportingPoint.x + hDir*widthPercent*tileSize, supportingPoint.y),
            vec2(supportingPoint.x, supportingPoint.y + vDir*heightPercent*tileSize)
        ];
        
        var shape: CollisionPolygon = new CollisionPolygon(verts);
        shape.transform.setPosition(origin);
        return shape;
    }

    public static inline function bboxBuild(widthPercent: Float, heightPercent: Float, offsetPercent: Vec2, origin: Vec2, tileSize: Float): CollisionShape {
        var shape: CollisionAABB = new CollisionAABB(widthPercent*tileSize, heightPercent*tileSize);
        shape.transform.setPosition(origin + offsetPercent*tileSize);
        return shape;
    }
}