package hcb.comp.btree;

import hcb.comp.btree.BehaviorNode.BehaviorNodeResult;

class BehaviorTreeSelectorNode  extends BehaviorNode {
    private var childIndex: Int = 0;
    
    public override function update(): BehaviorNodeResult {
        // * Goes through each child in order, stops and returns a success if one succeeds.
        // * Otherwise returns a falure after the last child returns a falure.
        if(children.length > 0) {
            var currentChild = children[childIndex];
            var result = currentChild.update();
            switch(result) {
                case BehaviorNodeResult.Continue:
                    return BehaviorNodeResult.Continue;
                
                case BehaviorNodeResult.Falure:
                    childIndex++;
                    if(childIndex >= children.length) {
                        childIndex = 0;
                        return BehaviorNodeResult.Falure;
                    }    
                
                case BehaviorNodeResult.Success:
                    childIndex = 0;
                    return BehaviorNodeResult.Success;

            }
        }
        return BehaviorNodeResult.Success;
    }
}