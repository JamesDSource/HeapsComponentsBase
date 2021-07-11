package hcb.comp;

import VectorMath;

class TransformComponent2D extends Component {
    public var transform(default, null): Transform2D;

    private override function set_parentEntity(parentEntity: Entity): Entity {
        var result = super.set_parentEntity(parentEntity);

        if(parent2d != null)
            transform.parent = parent2d.transform;
        
        return result;
    }

    public function new(name: String) {
        super(name);
        transform = new Transform2D();
    }
}