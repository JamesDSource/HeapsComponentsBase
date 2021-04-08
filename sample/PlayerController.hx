import hcb.Origin.OriginPoint;
import hcb.comp.anim.*;
import ldtk.Project;
import hxd.Key;
import hcb.comp.Component;
import hcb.comp.*;
import hcb.comp.col.*;
import hcb.math.Vector2;
import hxd.Res;

class PlayerController extends Component {

    private var transform: Transform2D;
    private var collisionBox: CollisionAABB;
    private var animationPlayer: AnimationPlayer;
    
    private var runSide: Animation;
    private var runFront: Animation;
    private var runBack: Animation;

    private var speed: Float = 4;

    public function new(name: String) {
        super(name);
    }

    public override function init() {
        transform = cast parentEntity.getComponentOfType(Transform2D);
        collisionBox = cast parentEntity.getComponentOfType(CollisionAABB);
        animationPlayer = cast parentEntity.getComponentOfType(AnimationPlayer);

        runSide = new Animation(Res.WitchRunSide.toTile(), 6, OriginPoint.bottomCenter);
        runFront = new Animation(Res.WitchRunFront.toTile(), 6, OriginPoint.bottomLeft, -9);
        runBack = new Animation(Res.WitchRunBack.toTile(), 6, OriginPoint.bottomLeft, -6);

        animationPlayer.addAnimationSlot("Default", 0);
        animationPlayer.setAnimationSlot("Default", runFront);
    }

    public override function update(delta: Float) {
        var moveVector: Vector2 = new Vector2();

        if(Key.isDown(Key.UP)) {
            moveVector.y -= 1;
            animationPlayer.setAnimationSlot("Default", runBack);
        }
        if(Key.isDown(Key.DOWN)) {
            moveVector.y += 1;
            animationPlayer.setAnimationSlot("Default", runFront);
        }
        if(Key.isDown(Key.LEFT)) {
            moveVector.x -= 1;
            animationPlayer.setAnimationSlot("Default", runSide);
            runSide.flipX = true;
        }
        if(Key.isDown(Key.RIGHT)) {
            moveVector.x += 1;
            animationPlayer.setAnimationSlot("Default", runSide);
            runSide.flipX = false;
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