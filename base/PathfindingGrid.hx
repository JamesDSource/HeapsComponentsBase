package base;

import base.math.Vector2;

typedef GridNode = {
    movementCostMult: Float,
    isObsticle: Bool 
}

class PathfindingGrid {
    private var cellSize: Float;
    private var gridSize: Vector2;
    private var originPoint: Vector2;
    
    public var grid: Array<Array<GridNode>> = [];
    
    public function new(cellSize: Float, gridSize: Vector2, ?originPoint: Vector2) {
        this.cellSize = cellSize;
        this.gridSize = gridSize;
        
        if(originPoint == null) {
            this.originPoint = new Vector2();
        }
        else {
            this.originPoint = originPoint;
        }

        // * Init grid of nodes
        for(i in 0...cast gridSize.x) {
            grid.push(new Array<GridNode>());
            for(j in 0...cast gridSize.y) {
                grid[i].push({movementCostMult: 1.0, isObsticle: false});
            }
        }

    }

    // & Gets the coordinates on the grid from a certain position
    public function positionToCoord(position: Vector2): Vector2 {
        var coords = position.divF(cellSize);
        coords.x = hxd.Math.clamp(Math.floor(coords.x), 0, gridSize.x - 1);
        coords.y = hxd.Math.clamp(Math.floor(coords.y), 0, gridSize.y - 1);
        return coords;
    }

    // & Gets the position of the center of a grid coordinate
    public function coordToPosition(coord: Vector2): Vector2 {
        var pos = coord.multF(cellSize);
        pos.addFMutate(cellSize/2 - 1);
        return pos;
    }

    // & Gets the closest grid point that isn't an obsticle
    public function getClosestCoord(position: Vector2): Vector2 {
        var coords = positionToCoord(position);
        if(grid[cast coords.x][cast coords.y].isObsticle = false) {
            return coords;
        }
        else {
            var opened: Array<Vector2> = [coords];
            var closed: Array<Vector2> = [];

            while(opened.length > 0) {
                var newOpened: Array<Vector2> = [];
                for(open in opened) {
                    var possibleSpaces: Array<Vector2> = [
                        new Vector2(open.x + 1, open.y),
                        new Vector2(open.x, open.y + 1),
                        new Vector2(open.x - 1, open.y),
                        new Vector2(open.x, open.y - 1),
                        new Vector2(open.x + 1, open.y + 1),
                        new Vector2(open.x - 1, open.y + 1),
                        new Vector2(open.x + 1, open.y - 1),
                        new Vector2(open.x - 1, open.y - 1)
                    ];

                    for(possibleSpace in possibleSpaces) {
                        if(possibleSpace.x < 0 || possibleSpace.x >= gridSize.x || possibleSpace.y < 0 || possibleSpace.y >= gridSize.y) {
                            continue;
                        }
                        else if(!newOpened.contains(possibleSpace) && !closed.contains(possibleSpace) && grid[cast possibleSpace.x][cast possibleSpace.y].isObsticle) {
                            newOpened.push(possibleSpace);
                        }
                        else if(!grid[cast possibleSpace.x][cast possibleSpace.y].isObsticle) {
                            return possibleSpace;
                        }
                    }

                    closed.push(open);
                }
                opened = newOpened;
            }
            return null;
        }
    }

    // & Gets the closest point that isn't an obsticle on the grid
    public function getClosestPoint(position: Vector2): Vector2 {
        var closestCoord: Vector2 = getClosestCoord(position);
        return coordToPosition(closestCoord);
    }

    // & Sets the movement cost of a single grid node 
    public function setMovementCostMult(coords: Vector2, newCost: Float): Void {
        grid[cast coords.x][cast coords.y].movementCostMult = newCost;
    }

    // & Clears all nodes that are obsticles
    public function clearObsticles() {
        for(i in 0...grid.length) {
            for(j in 0...grid[0].length) {
                grid[i][j].isObsticle = false;
            }
        }
    }

    // & Resets all movement cost multipliers back to one
    public function resetMovementCosts() {
        for(i in 0...grid.length) {
            for(j in 0...grid[0].length) {
                grid[i][j].movementCostMult = 1.0;
            }
        }
    }
    
    // & Resets all grid node values to their defaults
    public function resetGrid() {
        for(i in 0...grid.length) {
            for(j in 0...grid[0].length) {
                grid[i][j].isObsticle = false;
                grid[i][j].movementCostMult = 1.0;
            }
        }
    }

    // & Gets the path in grid coordinates
    public function getPathGrid(startCoord: Vector2, endCoord: Vector2): Array<Vector2> {
        return null;
    }

    // & Gets the path in pixel coordinates
    public function getPath(startPos: Vector2, endCoord: Vector2): Array<Vector2> {
        return null;
    }
}