package hcb.pathfinding;

class AStar {
    // & Gets the path in grid coordinates
    public static function getPath(startNode: Node, endNode: Node, ?maxIterations: Null<Int>): Array<Node> {
        if(endNode.obsticle) {
            return [];
        }
        
        var openSet: NodeHeap = new NodeHeap();
        var closedSet: Array<Node> = [];
        openSet.add(startNode);
        
        while(openSet.length > 0) {
            // * Find the position with the lowest F-cost
            // * Add lowest F-cost node to closed set, and remove
            // * from open set
            var currentNode: Node = openSet.removeFirst();
            closedSet.push(currentNode);

            if(currentNode == endNode) {
                var path = retracePath(startNode, endNode, maxIterations);
                return path;
            }

            for(node in currentNode.getConnecting()) {
                if(node.obsticle || closedSet.contains(node))
                    continue;

                var newMovementCost: Int = currentNode.gCost + currentNode.getDistance(node);
                if(newMovementCost < node.gCost || !openSet.contains(node)) {
                    node.gCost = newMovementCost;
                    node.hCost = node.getDistance(endNode);
                    node.parent = currentNode;

                    if(!openSet.contains(node)) {
                        openSet.add(node);
                    }
                }
            }
        }

        return [];
    }

    // & For the A* to trace back the nodes and create a path
    private static function retracePath(startNode: Node, endNode: Node, ?maxIterations: Null<Int>): Array<Node> {
        var path: Array<Node> = [];


        var currentNode: Node = endNode;
        var iteration: Int = 0;
        while(currentNode != startNode) {
            path.push(currentNode);

            if(currentNode.parent != null)
                currentNode = currentNode.parent;
            else 
                break;

            if(maxIterations != null && iteration > maxIterations) {
                trace("Warning: Max iterations in retracePath exceeded. Something's wrong with your pathfinding");
                break;
            }
            else
                iteration++;
        }

        path.reverse();
        return path;
    }
}