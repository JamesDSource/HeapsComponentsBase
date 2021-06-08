package hcb.comp;

import h2d.Object;
import h2d.Bitmap;
import h2d.Tile;
import hcb.Origin;
import VectorMath;

class Sprite extends Component {
    public var flipX(default, set): Bool = false;
    public var flipY(default, set): Bool = false;

    public var tile(default, set): Tile;
    public var originPoint(default, set): OriginPoint = OriginPoint.TopLeft;
    public var originOffsetX(default, set): Float = 0;
    public var originOffsetY(default, set): Float = 0;

    public var bitmap: Bitmap = new Bitmap();
    public var layer(default, set): Int;

    public var rotation(get, set): Float;

    public var unparentOverrideOnRoomRemove: Bool = true;
    public var parentOverride(default, set): h2d.Object = null;

    private function set_flipX(flipX: Bool): Bool {
        if(this.flipX != flipX) {
            tile.flipX();
            this.flipX = flipX;
        }
        return flipX;
    }

    private function set_flipY(flipY: Bool): Bool {
        if(this.flipY != flipY) {
            tile.flipY();
            this.flipY = flipY;
        }
        return flipY;
    }

    private function set_originPoint(originPoint: OriginPoint): OriginPoint {
        if(this.originPoint != originPoint) {
            this.originPoint = originPoint;
            setOrigin();
        }
        return originPoint;
    }

    private function set_originOffsetX(originOffsetX: Float): Float {
        if(this.originOffsetX != originOffsetX) {
            this.originOffsetX = originOffsetX;
            setOrigin();
        }
        return originOffsetX;
    }

    private function set_originOffsetY(originOffsetY: Float): Float {
        if(this.originOffsetY != originOffsetY) {
            this.originOffsetY = originOffsetY;
            setOrigin();
        }
        return originOffsetY;
    }

    private function set_tile(tile: Tile): Tile {
        this.tile = tile;
        bitmap.tile = tile;
        setOrigin();
        return tile;
    }

    private function set_layer(layer: Int): Int {
        if(parentEntity != null) {
            parentEntity.layers.removeChild(bitmap);
            parentEntity.layers.add(bitmap, layer);
        }
        
        this.layer = layer;
        return layer;
    }

    private function get_rotation(): Float {
        return bitmap.rotation;
    }

    private function set_rotation(rotation: Float): Float {
        bitmap.rotation = rotation;
        return rotation;
    }

    private function set_parentOverride(parentOverride: h2d.Object): h2d.Object {
        // * Remove from previous parent
        bitmap.remove();

        this.parentOverride = parentOverride;

        // * If null, add to the rooms to parentEntity
        if(parentOverride == null && parentEntity != null) {
            parentEntity.layers.add(bitmap, layer);
            return parentOverride;
        }

        // * If not null, add like normal
        if(parentOverride != null) {
            if(Std.isOfType(parentOverride, h2d.Layers)) {
                var layerParent: h2d.Layers = cast parentOverride;
                layerParent.add(bitmap, layer); 
            }  
            else
                parentOverride.addChild(bitmap);
        }
        
        return parentOverride;
    }

    public function new(name: String, ?tile: Tile, layer: Int = 0, originPoint: OriginPoint = OriginPoint.TopLeft, originOffsetX: Float = 0, originOffsetY: Float = 0) {
        super(name);
        this.tile = tile;
        this.layer = layer;
        this.originPoint = originPoint;
        this.originOffsetX = originOffsetX;
        this.originOffsetY = originOffsetY;
    }

    private override function init() {
        if(parentOverride == null)
            parentEntity.layers.add(bitmap, layer);
    }

    private override function onRemoved() {
        if(parentOverride == null || unparentOverrideOnRoomRemove)
            bitmap.remove();
    }

    private override function update() {
        var position: Vec2 = parentEntity.getPosition();
        // * Updating the position
        bitmap.x = position.x;
        bitmap.y = position.y;
    }

    private function setOrigin() {
        if(tile != null) {
            var w = tile.width;
            var h = tile.height;

            // * Setting the origin
            var offset: Vec2 = Origin.getOriginOffset(originPoint, vec2(w, h));
            tile.dx = offset.x + originOffsetX;
            tile.dy = offset.y + originOffsetY;
        }
    }

    public function addShader(s: hxsl.Shader) {
        bitmap.addShader(s);
    }

    public function removeShader(s: hxsl.Shader): Bool {
        return bitmap.removeShader(s);
    }

    public function getShaders() {
        return bitmap.getShaders();
    }
}