import VectorMath.normalize;
import haxe.display.Display.Package;
import h2d.Scene.ScaleModeAlign;
import h2d.Camera;
import hcb.Origin.OriginPoint;
import hcb.comp.anim.*;
import ldtk.Project;
import hxd.Key;
import hcb.comp.Component;
import hcb.comp.*;
import hcb.comp.col.*;
import VectorMath;
import hxd.Res;

class PlayerController extends Component {

    private var transform: Transform2D;
    private var collisionBox: CollisionAABB;
    private var animationPlayer: AnimationPlayer;
    
    private var idleSide: Animation;
    private var idleFront: Animation;
    private var idleBack: Animation;
    private var runSide: Animation;
    private var runFront: Animation;
    private var runBack: Animation;

    private var speed: Float = 2;

    private var camera: Camera;

    private var animationDirection: Vec2 = vec2(0, 0);

    public function new(name: String) {
        super(name);
    }

    public override function init() {
        transform = cast parentEntity.getComponentOfType(Transform2D);
        collisionBox = cast parentEntity.getComponentOfType(CollisionAABB);
        animationPlayer = cast parentEntity.getComponentOfType(AnimationPlayer);

        idleSide  = new Animation(Res.WitchIdleSide.toTile(), 3, 3, OriginPoint.bottomCenter);
        idleFront = new Animation(Res.WitchIdleFront.toTile(), 3, 3, OriginPoint.bottomCenter);
        idleBack  = new Animation(Res.WitchIdleBack.toTile(), 3, 3, OriginPoint.bottomCenter);
        runSide   = new Animation(Res.WitchRunSide.toTile(), 6, 10, OriginPoint.bottomCenter);
        runFront  = new Animation(Res.WitchRunFront.toTile(), 6, 10, OriginPoint.bottomCenter);
        runBack   = new Animation(Res.WitchRunBack.toTile(), 6, 10, OriginPoint.bottomCenter);

        animationPlayer.addAnimationSlot("Default", 0);
        animationPlayer.setAnimationSlot("Default", idleFront);

        camera = project.scene.camera;
        camera.anchorX = 0.5;
        camera.anchorY = 0.5;

        project.scene.scaleMode = ScaleMode.Stretch(480, 270);
    }

    public override function update(delta: Float) {
        var transformPos = transform.getPosition();
        var moveVector: Vec2 = vec2(0, 0);

        if(Key.isDown(Key.UP)) {
            moveVector.y -= 1;
            animationDirection = vec2(0, -1);
        }
        if(Key.isDown(Key.DOWN)) {
            moveVector.y += 1;
            animationDirection = vec2(0, 1);
        }
        if(Key.isDown(Key.LEFT)) {
            moveVector.x -= 1;
            animationDirection = vec2(-1, 0);
        }
        else if(Key.isDown(Key.RIGHT)) {
            moveVector.x += 1;
            animationDirection = vec2(1, 0);
        }
        moveVector = normalize(moveVector);
        moveVector *= speed;

        animate(animationDirection, moveVector != vec2(0, 0));

        var velocity: Vec2 = moveVector*delta;

        if(velocity.x != 0) {
            while(project.collisionWorld.isCollisionAt(collisionBox, transformPos + vec2(moveVector.x, 0))) {
                velocity.x = Math.max(velocity.x - 1, 0);
                if(velocity.x == 0) {
                    break;
                }
            }
        }

        if(velocity.y != 0) {
            while(project.collisionWorld.isCollisionAt(collisionBox, transformPos + vec2(0, moveVector.y))) {
                velocity.y = Math.max(velocity.y - 1, 0);
                if(velocity.y == 0) {
                    break;
                }
            }
        }

        transformPos += velocity;
        transform.moveTo(transformPos);

        camera.x = transformPos.x;
        camera.y = transformPos.y;
    }

    private function animate(direction: Vec2, moving: Bool) {
        if(direction.x != 0) {
            if(moving) {
                animationPlayer.setAnimationSlot("Default", runSide);
            }
            else {
                animationPlayer.setAnimationSlot("Default", idleSide);
            }

            runSide.flipX = idleSide.flipX = direction.x < 0;
        }
        else if(direction.y > 0) {
            if(moving) {
                animationPlayer.setAnimationSlot("Default", runFront);
            }
            else {
                animationPlayer.setAnimationSlot("Default", idleFront);
            }
        }
        else if(direction.y < 0) {
            if(moving) {
                animationPlayer.setAnimationSlot("Default", runBack);
            }
            else {
                animationPlayer.setAnimationSlot("Default", idleBack);
            }
        }
    }
}