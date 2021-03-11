package hcb.comp.btree;

import hcb.comp.btree.BehaviorNode.BehaviorNodeResult;

class BehaviorRootNode extends BehaviorNode {
    public override function update(delta: Float): BehaviorNodeResult {
        // * Just returns the result of the first child. All others are ignored
        if(children.length > 0) {
            if(children.length > 1) {
                trace("All children except the first are being unused. The root node should only have one child.");
            }
            return children[0].update(delta);
        }
        return BehaviorNodeResult.Success;
    }
}