package hcb.comp.btree;

enum BehaviorTreeNodeResult {
    Continue;
    Falure;
    Success;
}

class BehaviorTreeNode  {
    public var parent: BehaviorTreeNode = null;
    public var children: Array<BehaviorTreeNode> = [];
    
    public function new() {}

    public dynamic function update(): BehaviorTreeNodeResult {
        return BehaviorTreeNodeResult.Success;
    }

    public function addChild(newChild: BehaviorTreeNode): Void {
        if(newChild.parent != null) {
            newChild.parent.children.remove(newChild);
        }

        newChild.parent = this;
        children.push(newChild);
    }

    public function removeChild(child: BehaviorTreeNode): Void {
        children.remove(child);
        child.parent = null;
    }
}