import h2d.Tile;
import h2d.Bitmap;
import base.comp.Navigation;
import hxd.Key;
import haxe.io.Input;
import base.comp.Camera;
import base.comp.Transform2D;
import base.Entity;
import base.comp.Component;
import base.math.Vector2;

class PlayerController implements Component {
    public var parentEntity: Entity = null;
    public var updateable: Bool = true;
    public var name: String;

    public var speed: Float = 4;
    public var pathIndex: Int = 0;
    public var path: Array<Vector2> = [];

    public function new(name: String) {
        this.name = name;
    }

    public function init() {
    }

    public function update(delta: Float) {
        var transform: Transform2D = cast parentEntity.getSingleComponentOfType(Transform2D);
        var movementVector: Vector2 = new Vector2();
        
        if(Key.isPressed(Key.MOUSE_LEFT)) {
            var mx = parentEntity.project.scene.mouseX,
                my = parentEntity.project.scene.mouseY;

            var navi: Navigation = cast parentEntity.getComponent("Nav");
            path = navi.getPathTo(parentEntity.project.navigationGrids["Player"], new Vector2(mx, my));
            var renders = parentEntity.project.renderables;
            for(point in path) {
                var bmp = new h2d.Bitmap(Tile.fromColor(0x00FF00, 2, 2));
                bmp.x = point.x;
                bmp.y = point.y;
                trace(point.x, point.y);
                renders.add(bmp, 3);
            }
        }

        if(path.length > 0 && pathIndex < path.length) {
            var targetPoint: Vector2 = path[pathIndex];
            if(targetPoint.distanceTo(transform.position) < 2) {
                pathIndex++;
            }
            else {
                movementVector = targetPoint.subtract(transform.position).normalized();
                movementVector.multFMutate(speed*delta);  
            } 
        }

        transform.position.addMutate(movementVector);
    }

    public function onDestroy() {

    }
}