import base.Project;
import h2d.Tile;
import base.comp.*;

class Main extends hxd.App {

    private var proj: base.Project;

    private var player: Array<base.comp.Component> = [];

    override function init() {
        proj = new Project();
        setScene(proj.scene);

        var ap: AnimationPlayer = new AnimationPlayer(1);
        ap.addAnimation("Cube", Tile.fromColor(0xFF00000, 32, 32), 1);

        player = [
            new Transform2D(),
            new PlayerController(),
            ap
        ];

        proj.addEntity(player);
    }

    override function update(delta: Float) {
        proj.update(delta);
    }

    static function main() {
        hxd.Res.initLocal();
        new Main();
    }
}