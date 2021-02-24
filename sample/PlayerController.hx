import hxd.Key;
import haxe.io.Input;
import base.comp.Camera;
import base.comp.Transform2D;
import base.Entity;
import base.comp.Component;

class PlayerController implements Component {
    public var parentEntity: Entity = null;
    public var updateable: Bool = true;

    public var speed: Float = 6;

    public function new() {}

    public function init() {
    }

    public function update(delta: Float) {
        var transforms: Array<Component> = parentEntity.getComponentsOfType(Transform2D);
        if(transforms.length > 0) {
            var movementVector = new base.math.Vector2();
            if(Key.isDown(Key.RIGHT)) {
                movementVector.x += speed*delta;
            }
            if(Key.isDown(Key.LEFT)) {
                movementVector.x -= speed*delta;
            }
            if(Key.isDown(Key.DOWN)) {
                movementVector.y += speed*delta;
            }
            if(Key.isDown(Key.UP)) {
                movementVector.y -= speed*delta;
            }

            var transform: Transform2D = cast(transforms[0], Transform2D);
            transform.position.addMutate(movementVector);
        }
    }
}