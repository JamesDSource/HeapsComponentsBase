package hcb.tile;

import h2d.Tile;

class TileExt {
    public static function gridFlattenExt(t: Tile, hSize: Float, vSize: Float, dx: Float = 0., dy: Float = 0.) : Array<Tile> {
        var grid: Array<Tile> = [];

        for(y in 0...Std.int(t.height/vSize)) {
            for(x in 0...Std.int(t.width/hSize)) 
                grid.push(t.sub(x*hSize, y*vSize, hSize, vSize, dx, dy));
        }

        return grid;
    }
}