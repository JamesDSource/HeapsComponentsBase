package base;

import base.math.Vector2;

typedef GridNode = {
    movementCostMult: Float,
    isObsticle: Bool,
    gCost: Int,
    hCost: Int,
    parent: Vector2
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
                grid[i].push({movementCostMult: 1.0, isObsticle: false, gCost: 0, hCost: 0, parent: null});
            }
        }

    }

    // & Gets a node from a vector
    function get(index: Vector2): GridNode {
        return grid[cast index.x][cast index.y];
    }

    // & Gets all the nodes connecting to the index. The diagCheck argument determins if the function
    // & Will check if diagnal connections can be made
    function getConnecting(index: Vector2, diagCheck: Bool = true): Array<Vector2> {
        var possibleSpaces: Array<Vector2> = [];
        if(diagCheck) {
            possibleSpaces = [
                new Vector2(index.x + 1, index.y),  // * Right
                new Vector2(index.x, index.y + 1),  // * Down
                new Vector2(index.x - 1, index.y),  // * Left
                new Vector2(index.x, index.y - 1),  // * Up
            ];

            var rObs = get(possibleSpaces[0]).isObsticle,
                dObs = get(possibleSpaces[1]).isObsticle,
                lObs = get(possibleSpaces[2]).isObsticle,
                uObs = get(possibleSpaces[3]).isObsticle;

            if(!rObs && !dObs) {  // * Right Down
                possibleSpaces.push(new Vector2(index.x + 1, index.y + 1));
            }
            if(!lObs && !dObs) {  // * Left Down
                possibleSpaces.push(new Vector2(index.x - 1, index.y + 1));
            }
            if(!rObs && !uObs) {  // * Right up
                possibleSpaces.push(new Vector2(index.x + 1, index.y - 1));
            }
            if(!lObs && !uObs) {  // * Left up
                possibleSpaces.push(new Vector2(index.x - 1, index.y - 1));
            }
        }
        else {
            possibleSpaces = [
                new Vector2(index.x + 1, index.y),      // * Right    
                new Vector2(index.x, index.y + 1),      // * Down
                new Vector2(index.x - 1, index.y),      // * Left
                new Vector2(index.x, index.y - 1),      // * Up
                new Vector2(index.x + 1, index.y + 1),  // * Right down
                new Vector2(index.x - 1, index.y + 1),  // * Left down
                new Vector2(index.x + 1, index.y - 1),  // * Right up
                new Vector2(index.x - 1, index.y - 1)   // * Left up
            ];
        }

        var returnArray: Array<Vector2> = [];
        for(possibleSpace in possibleSpaces) {
            if(possibleSpace.x > 0 && possibleSpace.x < gridSize.x && possibleSpace.y > 0 || possibleSpace.y < gridSize.y) {
                returnArray.push(possibleSpace);
            }
        }

        return returnArray;
    }

    // & Gets the distance between two node positions with an abstract unit (not in pixels) 
    private function getDistance(positions1: Vector2, positions2: Vector2): Int {
        var distX: Int = cast Math.abs(positions1.x - positions2.x),
            distY: Int = cast Math.abs(positions1.y - positions2.y);
        
        
        if(distX < distY) {
            return cast 14*distX + 10*(distY - distX);
        }
        else {
            return cast 14*distY + 10*(distX - distY);
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
                    var possibleSpaces = getConnecting(open, false);
                    for(possibleSpace in possibleSpaces) {
                        if(!newOpened.contains(possibleSpace) && !closed.contains(possibleSpace) && grid[cast possibleSpace.x][cast possibleSpace.y].isObsticle) {
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
        var openSet: Array<Vector2> = [startCoord];
        var closedSet: Array<Vector2> = [];
        
        while(openSet.length > 0) {
            // * Find the position with the lowest F-cost
            var currentNodePos: Vector2 = openSet[0];
            for(i in 1...openSet.length) {
                var openNodePos: Vector2 = openSet[0],
                    openNode: GridNode = get(openNodePos),
                    currentNode: GridNode = get(currentNodePos);

                if(
                    openNode.gCost + openNode.hCost < currentNode.gCost + currentNode.hCost ||
                    (
                        openNode.gCost + openNode.hCost < currentNode.gCost + currentNode.hCost &&
                        openNode.hCost < currentNode.hCost
                    )
                ) {
                    currentNodePos = openNodePos;
                }
            }

            // * Add lowest F-cost node to closed set, and remove
            // * from open set
            closedSet.push(currentNodePos);
            openSet.remove(currentNodePos);

            if(currentNodePos == endCoord) {
                return retracePath(startCoord, endCoord);
            }

            for(nodePos in getConnecting(currentNodePos)) {
                var node: GridNode = get(nodePos);
                if(node.isObsticle || closedSet.contains(nodePos)) {
                    continue;
                }

                var newMovementCost: Int = get(currentNodePos).gCost + getDistance(currentNodePos, nodePos);
                if(newMovementCost < node.gCost || !openSet.contains(nodePos)) {
                    node.gCost = newMovementCost;
                    node.hCost = getDistance(nodePos, endCoord);
                    node.parent = currentNodePos;

                    if(!openSet.contains(nodePos)) {
                        openSet.push(nodePos);
                    }
                }
            }
        }

        return [];
    }

    // & Gets the path in pixel coordinates
    public function getPath(startPos: Vector2, endPos: Vector2): Array<Vector2> {
        var gridPath = getPathGrid(positionToCoord(startPos), positionToCoord(endPos));
        for(coord in gridPath) {
            coord = coordToPosition(coord);
        }
        return gridPath;
    }

    // & For the A* to trace back the nodes and create a path
    private function retracePath(startNode: Vector2, endNode: Vector2): Array<Vector2> {
        var path: Array<Vector2> = [];

        var currentNode: Vector2 = endNode;
        while(currentNode != startNode) {
            path.push(currentNode);
            currentNode = get(currentNode).parent;
        }
        path.reverse();
        return path;
    }
}