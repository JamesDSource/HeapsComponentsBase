package hcb.comp.btree;

class BehaviorTree extends Component {
    public var root: BehaviorRootNode;
    
    public function new(name: String = "Behavior Tree") {
        super(name);
        root = new BehaviorRootNode();
        root.tree = this;
    }

    private override function update() {
        root.update();
    }
}