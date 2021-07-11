package hcb;

import hcb.comp.Component;

class Entity2D extends Entity {
    public var transform(default, null): Transform2D;

    public var unparentOverrideOnRoomRemove: Bool = true;
    public var parentOverride(default, set): h2d.Object = null;
    public var layers(default, null): h2d.Layers = new h2d.Layers();
    public var layer(default, set): Int;

    private var onTranslatedEventListeners: Array<(Vec2) -> Void> = [];
    private var onRotatedEventListeners: Array<(Float) -> Void> = [];
    private var onScaledEventListeners: Array<(Vec2) -> Void> = [];

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

    public function new(?components: Array<Component>, x: Float = 0, y: Float = 0, layer: Int = 0) {
        transform = new Transform2D(x, y);
        transform.onTranslated = onTranslatedEventCall;
        transform.onRotated = onRotatedEventCall;
        transform.onScaled = onScaledEventCall;
        
        this.layer = layer;
        super(components);
    }

    // & Translated event
    public function onTranslatedEventSubscribe(callBack: Vec2 -> Void) {
        onTranslatedEventListeners.push(callBack);
    }

    public function onTranslatedEventRemove(callBack: Vec2 -> Void): Bool {
        return onTranslatedEventListeners.remove(callBack);
    }

    public function onTranslatedEventCall(position: Vec2) {
        for(listener in onTranslatedEventListeners)
            listener(position);
    }

    // & Rotated event
    public function onRotatedEventSubscribe(callBack: Float -> Void) {
        onRotatedEventListeners.push(callBack);
    }

    public function onRotatedEventRemove(callBack: Float -> Void): Bool {
        return onRotatedEventListeners.remove(callBack);
    }

    public function onRotatedEventCall(rotation: Float) {
        for(listener in onRotatedEventListeners)
            listener(rotation);
    }

    // & Scaled event
    public function onScaledEventSubscribe(callBack: Vec2 -> Void) {
        onScaledEventListeners.push(callBack);
    }

    public function onScaledEventRemove(callBack: Vec2 -> Void): Bool {
        return onScaledEventListeners.remove(callBack);
    }

    public function onScaledEventCall(scale: Vec2) {
        for(listener in onScaledEventListeners)
            listener(scale);
    }
}