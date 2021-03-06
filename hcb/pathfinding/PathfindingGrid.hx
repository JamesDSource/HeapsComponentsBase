package hcb.pathfinding;

import hcb.comp.col.CollisionAABB;
import hcb.comp.col.Collisions;
import hcb.comp.Transform2D;
import hcb.math.Vector2;

typedef GridNode = {
    movementCostMult: Float,
    isObsticle: Bool,
    gCost: Int,
    hCost: Int,
    parent: GridNode,
    heapIndex: Int,
    xPos: Int,
    yPos: Int
}

class PathfindingGrid {
    private var cellSize: Float;
    private var gridSize: Vector2;
    private var originPoint: Vector2;
    
    public var grid: Array<Array<GridNode>> = [];

    public var collisionShape: CollisionAABB;
    
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
                grid[i].push({movementCostMult: 1.0, isObsticle: false, gCost: 0, hCost: 0, parent: null, heapIndex: -1, xPos: i, yPos: j});
            }
        }


        // * Collision box
        collisionShape = new CollisionAABB("Checker", cellSize, cellSize);
    }

    // & Gets a node from a vector
    function get(index: Vector2): GridNode {
        return grid[cast index.x][cast index.y];
    }

    // & Checks if an index is in range
    function inRange(index: Vector2): Bool {
        return index.x > 0 && index.x < grid.length && index.y > 0 && index.y < grid[0].length;
    }

    // & Gets all the nodes connecting to the index. The diagCheck argument determins if the function
    // & Will check if diagnal connections can be made
    function getConnecting(index: GridNode, diagCheck: Bool = true): Array<GridNode> {
        var possibleSpaces: Array<Vector2> = [];
        var pos = new Vector2(index.xPos, index.yPos);
        if(diagCheck) {
            possibleSpaces = [
                new Vector2(pos.x + 1,  pos.y),     // * Right
                new Vector2(pos.x,      pos.y + 1), // * Down
                new Vector2(pos.x - 1,  pos.y),     // * Left
                new Vector2(pos.x,      pos.y - 1)  // * Up
            ];

            var rObs = inRange(possibleSpaces[0]) ? get(possibleSpaces[0]).isObsticle : false,
                dObs = inRange(possibleSpaces[1]) ? get(possibleSpaces[1]).isObsticle : false,
                lObs = inRange(possibleSpaces[2]) ? get(possibleSpaces[2]).isObsticle : false,
                uObs = inRange(possibleSpaces[3]) ? get(possibleSpaces[3]).isObsticle : false;

            if(!rObs && !dObs) {  // * Right Down
                possibleSpaces.push(new Vector2(pos.x + 1, pos.y + 1));
            }
            if(!lObs && !dObs) {  // * Left Down
                possibleSpaces.push(new Vector2(pos.x - 1, pos.y + 1));
            }
            if(!rObs && !uObs) {  // * Right up
                possibleSpaces.push(new Vector2(pos.x + 1, pos.y - 1));
            }
            if(!lObs && !uObs) {  // * Left up
                possibleSpaces.push(new Vector2(pos.x - 1, pos.y - 1));
            }
        }
        else {
            possibleSpaces = [
                new Vector2(pos.x + 1,  pos.y),      // * Right    
                new Vector2(pos.x,      pos.y + 1),  // * Down
                new Vector2(pos.x - 1,  pos.y),      // * Left
                new Vector2(pos.x,      pos.y - 1),  // * Up
                new Vector2(pos.x + 1,  pos.y + 1),  // * Right down
                new Vector2(pos.x - 1,  pos.y + 1),  // * Left down
                new Vector2(pos.x + 1,  pos.y - 1),  // * Right up
                new Vector2(pos.x - 1,  pos.y - 1)   // * Left up
            ];
        }

        var returnArray: Array<GridNode> = [];
        for(possibleSpace in possibleSpaces) {
            if(inRange(possibleSpace)) {
                returnArray.push(get(possibleSpace));
            }
        }

        return returnArray;
    }

    // & Gets the distance between two node positions with an abstract unit (not in pixels) 
    private function getDistance(node1: GridNode, node2: GridNode): Int {
        var distX: Int = cast Math.abs(node1.xPos - node2.xPos),
            distY: Int = cast Math.abs(node1.yPos - node2.yPos);
        
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
            var opened: Array<GridNode> = [get(coords)];
            var closed: Array<GridNode> = [];

            while(opened.length > 0) {
                var newOpened: Array<GridNode> = [];
                for(open in opened) {
                    var possibleSpaces = getConnecting(open, false);
                    for(possibleSpace in possibleSpaces) {
                        if(!newOpened.contains(possibleSpace) && !closed.contains(possibleSpace) && possibleSpace.isObsticle) {
                            newOpened.push(possibleSpace);
                        }
                        else if(!possibleSpace.isObsticle) {
                            return new Vector2(possibleSpace.xPos, possibleSpace.yPos);
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

    // & Sets the obsticle value of a single grid node 
    public function setIsObsticle(coords: Vector2, isObsticle: Bool): Void {
        grid[cast coords.x][cast coords.y].isObsticle = isObsticle;
    }

    // & Adds collision shapes with certain tags as obsticles
    public function addCollisionShapesTag(collisionWorld: CollisionWorld, tag: String) {
        for(shape in collisionWorld.shapes) {

            if(shape.tags.contains(tag)) {
                var bounds = shape.getBounds();
                var tl = positionToCoord(bounds.topLeft),
                    br = positionToCoord(bounds.bottomRight);

                for(i in cast(tl.x, Int)...cast br.x + 1) {
                    for(j in cast(tl.y, Int)...cast br.y + 1) {
                        var node = get(new Vector2(i, j));

                        if(!node.isObsticle) {
                            collisionShape.offset.set(i*cellSize, j*cellSize);

                            if(Collisions.test(collisionShape, shape)) {
                                node.isObsticle = true;
                            }
                        }
                    }
                }
            }
        }
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
        if(get(endCoord).isObsticle) {
            return [];
        }

        var openSet: hcb.pathfinding.NodeHeap = new hcb.pathfinding.NodeHeap();
        var closedSet: Array<GridNode> = [];
        openSet.add(get(startCoord));
        
        while(openSet.length > 0) {
            // * Find the position with the lowest F-cost
            // * Add lowest F-cost node to closed set, and remove
            // * from open set
            var currentNode: GridNode = openSet.removeFirst();
            closedSet.push(currentNode);

            if(currentNode == get(endCoord)) {
                return retracePath(startCoord, endCoord);
            }

            for(node in getConnecting(currentNode)) {
                if(node.isObsticle || closedSet.contains(node)) {
                    continue;
                }

                var newMovementCost: Int = currentNode.gCost + getDistance(currentNode, node);
                if(newMovementCost < node.gCost || !openSet.contains(node)) {
                    node.gCost = newMovementCost;
                    node.hCost = getDistance(node, get(endCoord));
                    node.parent = currentNode;

                    if(!openSet.contains(node)) {
                        openSet.add(node);
                    }
                }
            }
        }

        return [];
    }

    // & Gets the path in pixel coordinates
    public function getPath(startPos: Vector2, endPos: Vector2): Array<Vector2> {
        var gridPath = getPathGrid(positionToCoord(startPos), positionToCoord(endPos));
        var returnPath: Array<Vector2> = [];
        for(coord in gridPath) {
            var newCoord = coordToPosition(coord);
            returnPath.push(newCoord);
        }
        return returnPath;
    }

    // & For the A* to trace back the nodes and create a path
    private function retracePath(startNodePos: Vector2, endNodePos: Vector2): Array<Vector2> {
        var path: Array<Vector2> = [];

        var startNode = get(startNodePos),
            endNode = get(endNodePos);

        var dist = Math.ceil(startNodePos.distanceTo(endNodePos));

        var currentNode: GridNode = endNode;
        var iteration: Int = 0;
        while(currentNode != startNode) {
            path.push(new Vector2(currentNode.xPos, currentNode.yPos));
            if(currentNode.parent != null) {
                currentNode = currentNode.parent;
            }
            else {
                break;
            }

            if(iteration > dist*2) {
                break;
            }
            else {
                iteration++;
            }
        }
        path.reverse();
        return path;
    }
}