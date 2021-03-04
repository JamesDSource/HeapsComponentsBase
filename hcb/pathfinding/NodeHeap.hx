package hcb.pathfinding;

import hcb.pathfinding.PathfindingGrid.GridNode;

class NodeHeap {
    private var items: Array<GridNode> = [];
    public var length: Int = 0;

    public function new() {

    }

    public function add(item: GridNode) {
        item.heapIndex = length;
        items[length] = item;
        length++;
        sortUp(item);
    }

    public function removeFirst(): GridNode {
        if(length > 0) {
            var firstItem: GridNode = items[0];
            length--;
            var lastItem = items[length];
            lastItem.heapIndex = 0;
            items[0] = lastItem; 
            sortDown(items[0]);
            return firstItem;
        }
        else {
            return null;
        }
    }

    public function updateItem(item: GridNode) {
        sortUp(item);
        sortDown(item);
    }

    public function contains(item: GridNode): Bool {
        return items.contains(item);
    }

    public function sortDown(item: GridNode) {
        while(true) {
            var childIndexLeft: Int = item.heapIndex*2 + 1;
            var childIndexRight: Int = item.heapIndex*2 + 2;
            var swapIndex: Int = 0;

            if(childIndexLeft < length) {
                swapIndex = childIndexLeft;

                if(childIndexRight < length && compareTo(items[childIndexRight], items[childIndexLeft])) {
                    swapIndex = childIndexRight;
                }

                if(compareTo(items[swapIndex], item)) {
                    swap(item, items[swapIndex]);
                }
                else {
                    break;
                }
            }
            else {
                break;
            }
        }
    }

    private function sortUp(item: GridNode) {
        var parentIndex: Int = cast (item.heapIndex - 1)/2;

        while(true) {
            var parentItem: GridNode = items[parentIndex];
            if(compareTo(item, parentItem)) {
                swap(item, parentItem);
            }
            else {
                break;
            }
            parentIndex = cast (item.heapIndex - 1)/2;
        }
    }

    private function swap(itemA: GridNode, itemB: GridNode) {
        items[itemA.heapIndex] = itemB;
        items[itemB.heapIndex] = itemA;
        
        var itemAIndex: Int = itemA.heapIndex;
        itemA.heapIndex = itemB.heapIndex;
        itemB.heapIndex = itemAIndex;
    }

    private function compareTo(itemA: GridNode, itemB: GridNode): Bool {
        return itemA.gCost + itemA.hCost < itemB.gCost + itemB.hCost;
    }
}