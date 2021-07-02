package hcb.pathfinding;

class Node {
    @:allow(hcb.pathfinding.NodeHeap)
    private var heapIndex: Int = -1;

    @:allow(hcb.pathfinding.AStar)
    private var parent: Node = null;
    @:allow(hcb.pathfinding.AStar)
    private var hCost: Int = 0;
    @:allow(hcb.pathfinding.AStar)
    private var gCost: Int = 0;

    public var obsticle: Bool = false;

    public function getConnecting(): Array<Node> {
        return [];
    }
    
    public function getDistance(node: Node): Int {
        return 0;
    }

    public function compareTo(node: Node): Bool {
        return gCost + hCost < node.gCost + node.hCost;
    }

    public function reset() {
        hCost = gCost = 0;
        parent = null;
        heapIndex = -1;
    }
}