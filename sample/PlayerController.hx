import hcb.comp.col.CollisionAABB;
import hcb.CollisionWorld;
import h2d.Tile;
import h2d.Bitmap;
import hcb.comp.Navigation;
import hxd.Key;
import haxe.io.Input;
import hcb.comp.Transform2D;
import hcb.Entity;
import hcb.comp.Component;
import hcb.math.Vector2;

class PlayerController extends Component {

    public var speed: Float = 4;
    public var pathIndex: Int = 0;
    public var path: Array<Vector2> = [];

    public function new(name: String) {
        super(name);
    }

    public override function update(delta: Float) {
        var transform: Transform2D = cast parentEntity.getComponentOfType(Transform2D);
        var movementVector: Vector2 = new Vector2();
        
        if(Key.isPressed(Key.MOUSE_LEFT)) {
            var mx = parentEntity.project.scene.mouseX,
                my = parentEntity.project.scene.mouseY;

            var navi: Navigation = cast parentEntity.getComponent("Nav");
            path = navi.getPathTo(parentEntity.project.navigationGrids["Player"], new Vector2(mx, my));
            pathIndex = 0;
            var renders = parentEntity.project.renderables;
        }

        if(path.length > 0 && pathIndex < path.length) {
            var targetPoint: Vector2 = path[pathIndex];
            if(targetPoint.distanceTo(transform.position) < 2) {
                pathIndex++;
            }
            else {
                movementVector = targetPoint.subtract(transform.position);
                var len = movementVector.getLength();
                movementVector = movementVector.normalized();
                if(len < speed*delta) {
                    movementVector.multFMutate(len);
                }
                else {
                    movementVector.multFMutate(speed*delta);
                }
            } 
        }

        transform.position.addMutate(movementVector);
    }
}