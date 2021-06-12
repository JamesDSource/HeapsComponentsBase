import hcb.Origin.OriginPoint;
import hcb.comp.*;
import hcb.comp.col.*;
import hcb.comp.anim.*;
import hcb.Entity;
import VectorMath;

class PlayerEntity extends Entity {
    public function new(?position: Vec2, layer: Int = 0) {
        var components: Array<Component> = [
            new PlayerController("Controller"),
            new CollisionAABB("AABB", 10, 20, BottomCenter),
            new AnimationPlayer("Animations")
        ];

        super(components, position, layer);
    }

    public static function ldtkConvert(entity: Levels.Entity_Player): Entity {
        var position: Vec2 = vec2(entity.pixelX, entity.pixelY);
        return new PlayerEntity(position);
    }
}