package hcb;

import VectorMath;
import hcb.comp.Component.PauseMode;
import hcb.comp.*;

class Entity {
    public var room(default, set): Room = null;
    // ^ Should not be set directly outside the Room class
    private var components: Array<Component> = [];
    public var updatableComponents: Array<Component> = [];

    private var componentAddedEventListeners = new Array<Component -> Void>();
    private var componentRemovedEventListeners = new Array<Component -> Void>();

    private var position: Vec2 = vec2(0, 0);
    private var onMoveEventListeners: Array<(Vec2, Vec2) -> Void> = new Array<(Vec2, Vec2) -> Void>();

    public var unparentOverrideOnRoomRemove: Bool = true;
    public var parentOverride(default, set): h2d.Object = null;
    public var layers(default, null): h2d.Layers = new h2d.Layers();
    public var layer(default, set): Int;

    public var positionSnap(default, set): Bool = true;
    // ^ Makes sure that the position remains an integer value
    private var positionRemainder: Vec2 = vec2(0, 0);

    private function set_room(room: Room): Room {
        for(comp in components) {
            comp.room = room;
        }

        this.room = room;
        return room;
    }

    private function set_parentOverride(parentOverride: h2d.Object): h2d.Object {
        // * Remove from previous parent
        layers.remove();

        this.parentOverride = parentOverride;

        // * If null, add to the rooms drawTo
        if(parentOverride == null && room != null) {
            room.drawTo.add(layers, layer);
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

    private function set_positionSnap(positionSnap: Bool): Bool {
        if(this.positionSnap != positionSnap) {
            this.positionSnap = positionSnap;

            if(positionSnap)
                moveTo(position);
                // ^ Calling this will reset the remainder to whatever the current position is 
            else {
                move(positionRemainder);
                positionRemainder.x = positionRemainder.y = 0;
            }
        }
        return positionSnap;
    }

    public function new(?components: Array<Component>, ?position: Vec2, layer: Int = 0) {
        if(components != null)
            addComponents(components);

        if(position != null)
            this.position = position.clone();    

        this.layer = layer;
    }

    public function addComponent(component: Component): Void {
        if(component.parentEntity != null) {
            component.parentEntity.removeComponent(component);
        }

        components.push(component);
        if(component.updateable) {
            updatableComponents.push(component);
        }
        component.parentEntity = this;
        component.room = room;
        
        component.init();
        componentAddedEventCall(component);
    }

    public function addComponents(components: Array<Component>): Void {
        for(component in components) {
            if(component.parentEntity != null) {
                component.parentEntity.removeComponent(component);
            }
            
            this.components.push(component);
            if(component.updateable) {
                updatableComponents.push(component);
            }
            component.parentEntity = this;
            component.room = room;
            componentAddedEventCall(component);
        }

        for(component in components) {
            component.init();
        }
    }

    public function removeComponent(component: Component): Void {
        if(components.contains(component)) {
            component.onRemoved();
            components.remove(component);
            if(updatableComponents.contains(component)) {
                updatableComponents.remove(component);
            }

            componentRemovedEventCall(component);
            if(component.room != null) {
                component.removedFromRoom();
                component.room = null;
            }
            component.parentEntity = null;
        }
        else {
            trace("Trying to remove component that does not exist");
        }
    }

    public function clearComponents() {
        for(comp in components.copy()) {
            removeComponent(comp);
        }
    }

    public function remove() {
        if(room != null && room.hasEntity(this)) {
            room.removeEntity(this);
        }
    }

    @:allow(hcb.Room.update)
    private function update(paused: Bool = false): Void {
        for(updateableComponent in updatableComponents) {
            if(!paused || updateableComponent.pauseMode == PauseMode.Resume) {
                updateableComponent.update();
            }
        }
    }

    // & Gets all components
    public function getComponents(): Array<Component> {
        return components.copy();
    }

    // & Gets the first component with a particular name
    public function getComponent(name: String): Component {
        for(component in components) {
            if(component.name == name) {
                return component;
            }
        }
        return null;
    }

    // & Gets all components of the type you pass though, but you must cast it manually to an array of the type you want
    public function getAllComponentsOfType(t: Dynamic): Array<Component> {
        var returnList: Array<Component> = [];
        
        for(component in components) {
            if(Std.isOfType(component, t)) {
                returnList.push(component);
            }
        }
        return returnList;
    }

    // & Gets the first component of a particular type
    public function getComponentOfType(t: Dynamic): Component {
        for(component in components) {
            if(Std.isOfType(component, t)) {
                return component;
            }
        }
        return null;
    }

    // & Gets the entities position
    public function getPosition(): Vec2 {
        return position.clone();
    }

    // & Moves the position by a vector
    public function move(moveVector: Vec2) {
        var ev = onMoveEventCall.bind(_, position.clone());
        position += moveVector;

        if(positionSnap) {
            position += positionRemainder;
            positionRemainder = position - position.floor();
            position -= positionRemainder;
        }
        
        ev(position.clone());
    }

    // & Moves the position to a specific location vector
    public function moveTo(position: Vec2, resetRemainder: Bool = true) {
        var ev = onMoveEventCall.bind(_, this.position.clone());
        
        if(positionSnap) {
            if(resetRemainder)
                positionRemainder = position - position.floor();

            position = position.floor();
        }
        this.position = position.clone();
        ev(position.clone());
    }

    // & Sets the position remainder
    public function setPosRemainder(remainder: Vec2) {
        positionRemainder = remainder.clone();
        if(Math.abs(positionRemainder.x) >= 1 || Math.abs(positionRemainder.y) >= 1)
            move(vec2(0, 0));
    }

    // & gets the position remainder
    public function getPosRemainder(): Vec2 { 
        return positionRemainder.clone();
    }

    // & Component added event
    public function componentAddedEventSubscribe(callBack: Component -> Void) {
        componentAddedEventListeners.push(callBack);
    }

    public function componentAddedEventRemove(callBack: Component -> Void) {
        componentAddedEventListeners.remove(callBack);
    }

    private function componentAddedEventCall(component: Component) {
        for(listener in componentAddedEventListeners) {
            listener(component);
        }
    }

    // & Component removed event
    public function componentRemovedEventSubscribe(callBack: Component -> Void) {
        componentRemovedEventListeners.push(callBack);
    }

    public function componentRemovedEventRemove(callBack: Component -> Void) {
        componentRemovedEventListeners.remove(callBack);
    }

    private function componentRemovedEventCall(component: Component) {
        for(listener in componentRemovedEventListeners) {
            listener(component);
        }
    }

    // & on move event
    public function onMoveEventSubscribe(callBack: (Vec2, Vec2) -> Void) {
        onMoveEventListeners.push(callBack);
    }

    public function onMoveEventRemove(callBack: (Vec2, Vec2) -> Void) {
        onMoveEventListeners.remove(callBack);
    }

    private function onMoveEventCall(to: Vec2, from: Vec2) {
        for(listener in onMoveEventListeners) {
            listener(to, from);
        }
    }
}