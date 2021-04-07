import ldtk.Project;
import hxd.Key;
import hcb.comp.Component;
import hcb.comp.*;
import hcb.comp.col.*;
import hcb.math.Vector2;

class PlayerController extends Component {

    private var transform: Transform2D;
    private var collisionBox: CollisionAABB;
    
    private var speed: Float = 4;

    public function new(name: String) {
        super(name);
    }

    public override function init() {
        transform = cast parentEntity.getComponentOfType(Transform2D);
        collisionBox = cast parentEntity.getComponentOfType(CollisionAABB);
    }

    public override function update(delta: Float) {
        var moveVector: Vector2 = new Vector2();

        if(Key.isDown(Key.UP)) {
            moveVector.y -= 1;
        }
        if(Key.isDown(Key.DOWN)) {
            moveVector.y += 1;
        }
        if(Key.isDown(Key.LEFT)) {
            moveVector.x -= 1;
        }
        if(Key.isDown(Key.RIGHT)) {
            moveVector.x += 1;
        }
        moveVector = moveVector.normalized();
        moveVector.multFMutate(speed);

        var velocity: Vector2 = moveVector.multF(delta);

        while(project.collisionWorld.isCollisionAt(collisionBox, transform.position.add(new Vector2(moveVector.x, 0)))) {
            velocity.x = Math.max(velocity.x - 1, 0);
            if(velocity.x == 0) {
                break;
            }
        }

        while(project.collisionWorld.isCollisionAt(collisionBox, transform.position.add(new Vector2(0, moveVector.y)))) {
            velocity.y = Math.max(velocity.y - 1, 0);
            if(velocity.y == 0) {
                break;
            }
        }

        transform.position.addMutate(velocity);
    }
}