package hcb.tile;

import h2d.TileGroup;
import haxe.io.Bytes;
import hcb.IndexGrid.IndexGridData;
import VectorMath;

using hcb.tile.TileExt;

typedef AutoTileCases = {
    defaultTile: Int,

    ?b00000010: Int,
    ?b00001000: Int,
    ?b00001010: Int,
    ?b00001011: Int,
    ?b00010000: Int,
    ?b00010010: Int,
    ?b00010110: Int,
    
    ?b00011000: Int,
    ?b00011010: Int,
    ?b00011011: Int,
    ?b00011110: Int,
    ?b00011111: Int,
    ?b01000000: Int,
    ?b01000010: Int,
    ?b01001000: Int,

    ?b01001010: Int,
    ?b01001011: Int,
    ?b01010000: Int,
    ?b01010010: Int,
    ?b01010110: Int,
    ?b01011000: Int,
    ?b01011010: Int,
    ?b01011011: Int,

    ?b01011110: Int,
    ?b01011111: Int,
    ?b01101000: Int,
    ?b01101010: Int,
    ?b01101011: Int,
    ?b01111000: Int,
    ?b01111010: Int,
    ?b01111011: Int,

    ?b01111110: Int,
    ?b01111111: Int,
    ?b11010000: Int,
    ?b11010010: Int,
    ?b11010110: Int,
    ?b11011000: Int,
    ?b11011010: Int,
    ?b11011011: Int,

    ?b11011110: Int,
    ?b11011111: Int,
    ?b11111000: Int,
    ?b11111010: Int,
    ?b11111011: Int,
    ?b11111110: Int,
    ?b11111111: Int,
    ?b00000000: Int
}

class AutoTile {
    public static final presetAutoTileCases: AutoTileCases = {
        defaultTile: 12,

        b00000010: 25,
        b00001000: 35,
        b00001010: 40,
        b00001011: 24,
        b00010000: 33,
        b00010010: 37,
        b00010110: 22,

        b00011000: 34,
        b00011010: 41,
        b00011011: 38,
        b00011110: 39,
        b00011111: 23,
        b01000000: 3,
        b01000010: 14,
        b01001000: 7,

        b01001010: 51,
        b01001011: 18,
        b01010000: 4,
        b01010010: 48,
        b01010110: 15,
        b01011000: 8,
        b01011010: 52,
        b01011011: 43,

        b01011110: 42,
        b01011111: 19,
        b01101000: 2,
        b01101010: 29,
        b01101011: 13,
        b01111000: 5,
        b01111010: 32,
        b01111011: 49,

        b01111110: 20,
        b01111111: 16,
        b11010000: 0,
        b11010010: 26,
        b11010110: 11,
        b11011000: 6,
        b11011010: 31,
        b11011011: 9,

        b11011110: 50,
        b11011111: 17,
        b11111000: 1,
        b11111010: 30,
        b11111011: 27,
        b11111110: 28,
        b11111111: 12,
        b00000000: 36
    }


    public var indexGrid: IndexGridData;
    private var bytes: Bytes;

    public var tile(default, set): h2d.Tile;
    private var slicedTiles: Array<h2d.Tile> = [];
    private var tileWidth: Float;
    private var tileHeight: Float;

    public var tileMappings: Map<Int, {cases: AutoTileCases, ?offset: Null<Int>, ?canSee: Int -> Bool}> = [];

    private inline function set_tile(tile: h2d.Tile): h2d.Tile {
        this.tile = tile;
        if(tile != null)
            cutTiles();
        return tile;
    }

    public function new(indexGrid: IndexGridData, tile: h2d.Tile, tileWidth: Float, ?tileHeight: Null<Float>) {
        this.indexGrid = indexGrid;

        this.tileWidth = tileWidth;
        this.tileHeight = tileHeight == null ? tileWidth : tileHeight;
        
        this.tile = tile;
    }

    public inline function setTileSize(tileWidth: Float, tileHeight: Float) {
        this.tileWidth = tileWidth;
        this.tileHeight = tileHeight;
        cutTiles();
    }

    private inline function cutTiles() {
        slicedTiles = tile.gridFlattenExt(tileWidth, tileHeight);
    }

    public function imprintBytes(diagonals: Bool = true) {
        bytes = Bytes.alloc(indexGrid.indexs.length);
        
        var w = indexGrid.width;
        var h = indexGrid.height;
        for(i in 0...indexGrid.indexs.length) {
            if(indexGrid.indexs[i] == -1)
                continue;

            var accumulator: Int = 0;
            var sides: Array<Vec2> = [
                vec2(-1, -1),
                vec2(0, -1),
                vec2(1, -1),
                vec2(-1, 0),
                vec2(1, 0),
                vec2(-1, 1),
                vec2(0, 1),
                vec2(1, 1)
            ];

            for(j in 0...sides.length) {
                var x: Int = Std.int(i%w + sides[j].x);
                var y: Int = Std.int(Math.floor(i/w) + sides[j].y);
                if(x < 0 || x >= w || y < 0 || y >= h)
                    continue;

                var index = y*w + x;

                if(indexGrid.indexs[index] != -1) {
                    // * Check if it's a diagonal, if so, make sure that each component isn't empty
                    if(sides[j].x != 0 && sides[j].y != 0) {
                        if(!diagonals)
                            continue;

                        var verticalIndex: Int = y*w + Std.int(i%w);
                        var horizontalIndex: Int = Math.floor(i/w)*w + x;

                        if(indexGrid.indexs[verticalIndex] == -1 || indexGrid.indexs[horizontalIndex] == -1)
                            continue;
                    }

                    // * Add this sides bit to the accumulator
                    accumulator += Std.int(Math.pow(2, j));
                }
            }

            bytes.set(i, accumulator);
        }
    }

    public inline function render(?tileGroup: h2d.TileGroup): h2d.TileGroup {
        if(tileGroup == null)
            tileGroup = new h2d.TileGroup(tile);

        var data = bytes.getData();
        for(i in 0...indexGrid.indexs.length) {
            if(indexGrid.indexs[i] == -1 || !tileMappings.exists(indexGrid.indexs[i]))
                continue;
            
            var v = Bytes.fastGet(data, i);
            var mappings = tileMappings[indexGrid.indexs[i]];
            var tileIndex: Null<Int> = getMaskIndex(v, mappings.cases);
            if(tileIndex == null)
                tileIndex = mappings.cases.defaultTile;

            if(mappings.offset != null)
                tileIndex += mappings.offset;
            
            var x = i%indexGrid.width;
            var y = Math.floor(i/indexGrid.width);
            tileGroup.add(x*tileWidth, y*tileHeight, slicedTiles[tileIndex]);
        }
        
        return tileGroup;
    }

    private inline function getMaskIndex(v: Int, cases: AutoTileCases): Null<Int> {
        switch(v) {
            case 0:     return cases.b00000000;
            case 2:     return cases.b00000010;
            case 8:     return cases.b00001000;
            case 10:    return cases.b00001010;
            case 11:    return cases.b00001011;
            case 16:    return cases.b00010000;
            case 18:    return cases.b00010010;
            case 22:    return cases.b00010110;
            case 24:    return cases.b00011000;
            case 26:    return cases.b00011010;
            case 27:    return cases.b00011011;
            case 30:    return cases.b00011110;
            case 31:    return cases.b00011111;
            case 64:    return cases.b01000000;
            case 66:    return cases.b01000010;
            case 72:    return cases.b01001000;
            case 74:    return cases.b01001010;
            case 75:    return cases.b01001011;
            case 80:    return cases.b01010000;
            case 82:    return cases.b01010010;
            case 86:    return cases.b01010110;
            case 88:    return cases.b01011000;
            case 90:    return cases.b01011010;
            case 91:    return cases.b01011011;
            case 94:    return cases.b01011110;
            case 95:    return cases.b01011111;
            case 104:   return cases.b01101000;
            case 106:   return cases.b01101010;
            case 107:   return cases.b01101011;
            case 120:   return cases.b01111000;
            case 122:   return cases.b01111010;
            case 123:   return cases.b01111011;
            case 126:   return cases.b01111110;
            case 127:   return cases.b01111111;
            case 208:   return cases.b11010000;
            case 210:   return cases.b11010010;
            case 214:   return cases.b11010110;
            case 216:   return cases.b11011000;
            case 218:   return cases.b11011010;
            case 219:   return cases.b11011011;
            case 222:   return cases.b11011110;
            case 223:   return cases.b11011111;
            case 248:   return cases.b11111000;
            case 250:   return cases.b11111010;
            case 251:   return cases.b11111011;
            case 254:   return cases.b11111110;
            case 255:   return cases.b11111111;
            default:    return cases.defaultTile;
        }
    }
}