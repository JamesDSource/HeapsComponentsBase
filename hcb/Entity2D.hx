package hcb;

import hcb.comp.Component;

class Entity2D extends Entity {
    public var transform(default, null): Transform2D;

    public var unparentOverrideOnRoomRemove: Bool = true;
    public var parentOverride(default, set): h2d.Object = null;
    public var layers(default, null): h2d.Layers = new h2d.Layers();
    public var layer(default, set): Int;

    private function set_parentOverride(parentOverride: h2d.Object): h2d.Object {
        this.parentOverride = parentOverride;
        
        // * Remove from previous parent
        layers.remove();

        // * If null, add to the rooms drawTo
        if(parentOverride == null && room2d != null) {
            room2d.drawTo.add(layers, layer);
            return parentOverride;
        }

        // * If not null, add like normal
        if(parentOverride != null) {
            if(Std.isOfType(parentOverride, h2d.Layers)) {
                var layerParent: h2d.Layers = cast parentOverride;
                layerParent.add(layers, layer); 
            }  
            else
                parentOverride.addChild(layers);
        }
        
        return parentOverride;
    }

    private function set_layer(layer: Int): Int {
        this.layer = layer;
        var parent = layers.parent;
        if(parent != null && Std.isOfType(parent, h2d.Layers)) {
            var layerParent: h2d.Layers = cast parent;
            layers.remove();
            layerParent.add(layers, layer);
        }

        return layer;
    }

    public function new(?components: Array<Component>, layer: Int = 0) {
        super(components);
        this.layer = layer;
    }
}