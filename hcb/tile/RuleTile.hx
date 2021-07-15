package hcb.tile;

import VectorMath;

using hcb.tile.TileExt;

enum ConditionsNeeded {
    All;
    None;
    Any;
    Custom(condition: (Int) -> Bool);
}

typedef TileCondition = {
    dx: Int,
    dy: Int,
    assume: Bool,
    ?indexIs: Array<Int>,
    ?indexIsNot: Array<Int>,
    ?customCondition: Int -> Bool
}

typedef TileRule = {
    tileIndex: Int,
    chance: Float,
    // ^ Ranges from 0-1
    conditions: Array<TileCondition>,
    conditionsNeeded: ConditionsNeeded,
    ?onIndex: Int
}


class RuleTile {
    public var indexGrid: IndexGrid;
    public var tile(default, set): h2d.Tile;
    private var slicedTiles: Array<h2d.Tile> = [];

    private var tileWidth: Float;
    private var tileHeight: Float;

    public var rules: Array<TileRule> = [];
    private var rng: hxd.Rand;
    public var seed: Int;

    private var indexs: Array<Int> = [];

    private inline function set_tile(tile: h2d.Tile): h2d.Tile {
        this.tile = tile;
        cutTiles();
        return tile;
    }


    public function new(indexGrid: IndexGrid, tile: h2d.Tile, tileWidth: Float, tileHeight: Float, seed: Int = 5381) {
        this.indexGrid = indexGrid;
        
        this.tileWidth = tileWidth;
        this.tileHeight = tileHeight;

        this.tile = tile;

        rng = hxd.Rand.create();
        this.seed = seed;
    }

    public inline function setTileSize(tileWidth: Float, tileHeight: Float) {
        this.tileWidth = tileWidth;
        this.tileHeight = tileHeight;
        cutTiles();
    }

    private inline function cutTiles() {
        slicedTiles = tile.gridFlattenExt(tileWidth, tileHeight);
    }

    public function render(?tileGroup: h2d.TileGroup): h2d.TileGroup {
        if(tileGroup == null)
            tileGroup = new h2d.TileGroup(tile);

        for(i in 0...indexs.length) {
            if(indexs[i] < 0)
                continue;

            var position = indexGrid.getCoords(i)*vec2(tileWidth, tileHeight);
            tileGroup.add(position.x, position.y, slicedTiles[indexs[i]]);
        }

        return tileGroup;
    }

    public function getLayout(): IndexGrid {
        var iGrid = new IndexGrid(indexGrid.width, indexGrid.height, -1);
        iGrid.copyIndexs(indexs);
        return iGrid;
    }

    public function generateLayout() {
        rng.init(seed);
        indexs = [];

        for(i in 0...indexGrid.length) {
            var tileIndex: Int = -1;
            var found: Bool = false;
            for(rule in rules) {
                if(found)
                    rng.rand();
                else if(ruleIsMet(i, rule)) {
                    tileIndex = rule.tileIndex;
                    found = true;
                }
            }

            indexs.push(tileIndex);
        }
    }

    private function ruleIsMet(position: Int, rule: TileRule): Bool {
        if(rng.rand() >= rule.chance || (rule.onIndex != null && rule.onIndex != indexGrid[position]))
            return false;

        var conditionsMet: Int = 0;
        var conditionsTotal: Int = rule.conditions.length;

        for(condition in rule.conditions)
            conditionsMet += conditionIsMet(position, condition) ? 1 : 0;

        switch(rule.conditionsNeeded) {
            case All:
                if(conditionsMet == conditionsTotal)
                    return true;
            case None:
                if(conditionsMet == 0)
                    return true;
            case Any:
                if(conditionsMet > 0)
                    return true;
            case Custom(condition):
                return condition(conditionsMet);
        }

        return false;
    }

    private function conditionIsMet(position: Int, condition: TileCondition): Bool {
        var coords = indexGrid.getCoords(position) + vec2(condition.dx, condition.dy);        
        if(!indexGrid.inRange(Std.int(coords.x), Std.int(coords.y)))
            return condition.assume;

        var i = indexGrid.coordsToIndex(Std.int(coords.x), Std.int(coords.y));
        var index = indexGrid[i];

        if(condition.customCondition != null)
            return condition.customCondition(index);
        
        if(condition.indexIsNot != null)
            return !condition.indexIsNot.contains(index);

        if(condition.indexIs != null)
            return condition.indexIs.contains(index);

        return condition.assume;
    }
}