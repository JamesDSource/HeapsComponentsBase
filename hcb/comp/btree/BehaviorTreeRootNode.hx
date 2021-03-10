package hcb.comp.btree;

import hcb.comp.btree.BehaviorTreeNode.BehaviorTreeNodeResult;

class BehaviorTreeRootNode extends BehaviorTreeNode {
    public override function update(): BehaviorTreeNodeResult {
        // * Just returns the result of the first child. All others are ignored
        if(children.length > 0) {
            if(children.length > 1) {
                trace("All children except the first are being unused. The root node should only have one child.");
            }
            return children[0].update();
        }
        return BehaviorTreeNodeResult.Success;
    }
}