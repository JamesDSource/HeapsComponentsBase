package hcb.comp.btree;

import hcb.comp.btree.BehaviorTreeNode.BehaviorTreeNodeResult;

class BehaviorTreeSelectorNode  extends BehaviorTreeNode {
    private var childIndex: Int = 0;
    
    public override function update(): BehaviorTreeNodeResult {
        // * Goes through each child in order, stops and returns a success if one succeeds.
        // * Otherwise returns a falure after the last child returns a falure.
        if(children.length > 0) {
            var currentChild = children[childIndex];
            var result = currentChild.update();
            switch(result) {
                case BehaviorTreeNodeResult.Continue:
                    return BehaviorTreeNodeResult.Continue;
                
                case BehaviorTreeNodeResult.Falure:
                    childIndex++;
                    if(childIndex >= children.length) {
                        childIndex = 0;
                        return BehaviorTreeNodeResult.Falure;
                    }    
                
                case BehaviorTreeNodeResult.Success:
                    childIndex = 0;
                    return BehaviorTreeNodeResult.Success;

            }
        }
        return BehaviorTreeNodeResult.Success;
    }
}