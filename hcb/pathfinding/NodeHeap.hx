package hcb.pathfinding;

class NodeHeap {
    private var items: Array<Node> = [];
    public var length: Int = 0;

    public function new() {}

    public function add(item: Node) {
        item.heapIndex = length;
        items[length] = item;
        length++;
        sortUp(item);
    }

    public function removeFirst(): Node {
        if(length > 0) {
            var firstItem: Node = items[0];
            length--;
            var lastItem = items[length];
            lastItem.heapIndex = 0;
            items[0] = lastItem; 
            sortDown(items[0]);
            return firstItem;
        }
        else
            return null;
    }

    public function updateItem(item: Node) {
        sortUp(item);
        sortDown(item);
    }

    public function contains(item: Node): Bool {
        return items.contains(item);
    }

    public function sortDown(item: Node) {
        while(true) {
            var childIndexLeft: Int = item.heapIndex*2 + 1;
            var childIndexRight: Int = item.heapIndex*2 + 2;
            var swapIndex: Int = 0;

            if(childIndexLeft < length) {
                swapIndex = childIndexLeft;

                if(childIndexRight < length && items[childIndexRight].compareTo(items[childIndexLeft]))
                    swapIndex = childIndexRight;

                if(items[swapIndex].compareTo(item))
                    swap(item, items[swapIndex]);
                else
                    break;
            }
            else
                break;
        }
    }

    private function sortUp(item: Node) {
        var parentIndex: Int = cast (item.heapIndex - 1)/2;

        while(true) {
            var parentItem: Node = items[parentIndex];
            if(item.compareTo(parentItem))
                swap(item, parentItem);
            else
                break;

            parentIndex = cast (item.heapIndex - 1)/2;
        }
    }

    private function swap(itemA: Node, itemB: Node) {
        items[itemA.heapIndex] = itemB;
        items[itemB.heapIndex] = itemA;
        
        var itemAIndex: Int = itemA.heapIndex;
        itemA.heapIndex = itemB.heapIndex;
        itemB.heapIndex = itemAIndex;
    }
}