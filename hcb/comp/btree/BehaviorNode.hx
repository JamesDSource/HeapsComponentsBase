package hcb.comp.btree;

enum BehaviorNodeResult {
    Continue;
    Falure;
    Success;
}

class BehaviorNode  {
    public var parent: BehaviorNode = null;
    public var children: Array<BehaviorNode> = [];
    public var tree: BehaviorTree;
    
    public function new() {}

    public dynamic function update(): BehaviorNodeResult {
        return BehaviorNodeResult.Success;
    }

    public function addChild(newChild: BehaviorNode): Void {
        if(newChild.parent != null) {
            newChild.parent.children.remove(newChild);
        }

        newChild.parent = this;
        newChild.tree = tree;
        children.push(newChild);
    }

    public function removeChild(child: BehaviorNode): Void {
        children.remove(child);
        child.tree = null;
        child.parent = null;
    }
}