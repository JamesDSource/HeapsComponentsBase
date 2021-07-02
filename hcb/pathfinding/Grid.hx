package hcb.pathfinding;

import hcb.comp.col.*;
import VectorMath;

class Grid {
    private var cellSize: Float;
    private var cWidth: Int;
    private var cHeight: Int;
    public var grid: Array<GridNode> = [];

    public var originPoint: Vec2;
    public var collisionShape: CollisionAABB;
    
    public function new(cellSize: Float, cWidth: Int, cHeight: Int, ?originPoint: Vec2) {
        this.cellSize = cellSize;
        this.cWidth = cWidth;
        this.cHeight = cHeight;
        this.originPoint =  originPoint == null ? vec2(0, 0): originPoint;


        // * Init grid of nodes
        for(i in 0...cWidth*cHeight) {
            var y: Int = Math.floor(i/cWidth);
            var x: Int = Math.floor(i%cWidth);
            grid.push(new GridNode(x, y, this));
        }


        // * Collision box
        collisionShape = new CollisionAABB("Checker", cellSize, cellSize);
    }

    // & Gets a node from a vector
    public inline function get(index: Vec2): GridNode {
        var i: Int = Std.int(index.y*cWidth + index.x);
        return grid[i];
    }

    // & Checks if an index is in range
    public inline function inRange(index: Vec2): Bool {
        return index.x >= 0 && index.x < cWidth && index.y >= 0 && index.y < cHeight;
    }

    // & Gets the coordinates on the grid from a certain position
    public function positionToCoord(position: Vec2): Vec2 {
        var coords = (position - originPoint)/cellSize;
        coords.x = hxd.Math.clamp(Math.floor(coords.x), 0, cWidth - 1);
        coords.y = hxd.Math.clamp(Math.floor(coords.y), 0, cHeight - 1);
        return coords;
    }

    // & Gets the position of the center of a grid coordinate
    public function coordToPosition(coord: Vec2): Vec2 {
        var pos = coord*cellSize;
        pos += cellSize/2;
        return pos + originPoint;
    }

    // & Gets the closest grid point that isn't an obsticle
    public function getClosestCoord(position: Vec2): Vec2 {
        var coords = positionToCoord(position);
        if(!get(coords).obsticle)
            return coords;
        else {
            var opened: Array<GridNode> = [get(coords)];
            var closed: Array<GridNode> = [];

            while(opened.length > 0) {
                var newOpened: Array<GridNode> = [];
                for(open in opened) {
                    open.diagCheckConnecting = false;
                    var possibleSpaces = open.getConnecting();
                    open.diagCheckConnecting = true;
                    for(possibleSpace in possibleSpaces) {
                        var ps = cast(possibleSpace, GridNode);

                        if(!newOpened.contains(ps) && !closed.contains(ps) && ps.obsticle)
                            newOpened.push(ps);
                        else if(!ps.obsticle)
                            return vec2(ps.x, ps.y);
                    }

                    closed.push(open);
                }
                opened = newOpened;
            }
            return null;
        }
    }

    // & Sets the obsticle value of a single grid node 
    public function setIsObsticle(coords: Vec2, obsticle: Bool): Void {
        get(coords).obsticle = obsticle;
    }

    // & Adds collision shapes with certain tags as obsticles
    public function addCollisionShapes(collisionWorld: hcb.col.CollisionWorld, ?tag: Null<String>) {
        for(node in grid) {
            if(!node.obsticle)
                node.obsticle = collisionWorld.getCollisionAt(collisionShape, originPoint + vec2(node.x*cellSize, node.y*cellSize), tag) != null;
        }
    }

    // & Clears all nodes that are obsticles
    public function clearObsticles() {
        for(node in grid)
            node.obsticle = false;
    }

    public function getPath(startPosition: Vec2, endPosition: Vec2, convertToWorldCoords: Bool = true): Array<Vec2> {
        var nodes = AStar.getPath(get(startPosition), get(endPosition));

        var positions: Array<Vec2> = [];
        for(node in nodes) {
            var gridNode: GridNode = cast(node, GridNode);

            if(convertToWorldCoords) {
                var position = originPoint + vec2(gridNode.x, gridNode.y)*cellSize;
                positions.push(position);
            }
            else
                positions.push(vec2(gridNode.x, gridNode.y));
        }

        return positions;
    }
    
    /*
    // & Returns an h2d.Graphics that draws a representation of the grid
    public function represent(a: Float = 0.6): h2d.Graphics {
        var g: h2d.Graphics = new h2d.Graphics();
        g.lineStyle(1, 0xFFFFFF, a);
        g.x = originPoint.x;
        g.y = originPoint.y;
        for(i in 0...Std.int(gridSize.x)) {
            for(j in 0...Std.int(gridSize.y)) {
                g.beginFill(get(vec2(i, j)).isObsticle ? 0xFF0000 : 0x00FF00, a);
                g.drawRect(i*cellSize, j*cellSize, cellSize, cellSize);
            }
        }
        return g;
    }
    */
}