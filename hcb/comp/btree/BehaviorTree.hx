package hcb.comp.btree;

class BehaviorTree extends Component {
    public var root: BehaviorRootNode;
    
    public function new(name: String) {
        super(name);
        root = new BehaviorRootNode();
        root.tree = this;
    }

    public override function update(delta:Float) {
        root.update(delta);
    }
}