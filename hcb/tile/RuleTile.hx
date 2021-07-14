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

    private var rules: Array<TileRule> = [];
    private var rng: hxd.Rand;
    public var seed: Int;

    private inline function set_tile(tile: h2d.Tile): h2d.Tile {
        this.tile = tile;
        cutTiles();
        return tile;
    }

    public function new(tile: h2d.Tile, tileWidth: Float, tileHeight: Float, seed: Int = 5381) {
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

    public function generateLayout() {
        rng.init(seed);

        for(i in 0...indexGrid.length) {
            var tileIndex: Int = -1;
            for(rule in rules) {
                if(ruleIsMet(i, rule)) {
                    tileIndex = rule.tileIndex;
                    break;
                }
            }
        }
    }

    public function render() {

    }

    private function ruleIsMet(position: Int, rule: TileRule): Bool {
        if((rule.onIndex != null && rule.onIndex != indexGrid[position]) || rng.rand() >= rule.chance)
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
        
        if(condition.indexIsNot != null && condition.indexIsNot.contains(index))
            return false;

        if(condition.indexIs != null && condition.indexIs.contains(index))
            return true;

        return condition.assume;
    }

    public inline function addRule(rule: TileRule) {
        rules.push(rule);
    }

    public inline function removeRule(rule: TileRule): Bool {
        return rules.remove(rule);
    }

    public inline function hasRule(rule: TileRule): Bool {
        return rules.contains(rule);
    }
}