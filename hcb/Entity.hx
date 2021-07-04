package hcb;

import VectorMath;
import hcb.Pause.PauseState;
import hcb.comp.*;
import hcb.struct.*;

class Entity {
    @:allow(hcb.struct.Room)
    private var roomIn(default, set): Room = null;
    public var room(get, null): Room;
    public var room2d(default, null): Room2D;
    public var room3d(default, null): Room3D;

    private var components: Array<Component> = [];
    public var updatableComponents: Array<Component> = [];

    private var componentAddedEventListeners = new Array<Component -> Void>();
    private var componentRemovedEventListeners = new Array<Component -> Void>();

    private var position: Vec3 = vec3(0, 0, 0);
    private var onMoveEventListeners: Array<(Vec3, Vec3) -> Void> = new Array<(Vec3, Vec3) -> Void>();

    public var unparentOverrideOnRoomRemove: Bool = true;
    public var parentOverride(default, set): h2d.Object = null;
    public var layers(default, null): h2d.Layers = new h2d.Layers();
    public var layer(default, set): Int;

    public var positionSnap(default, set): Bool = true;
    // ^ Makes sure that the position remains an integer value
    private var positionRemainder: Vec3 = vec3(0, 0, 0);

    public var pauseState: PauseState = Idle;

    private function set_roomIn(roomIn: Room): Room {
        room2d = null;
        room3d = null;
        
        if(Std.isOfType(roomIn, Room2D))
            room2d = cast roomIn;
        else if(Std.isOfType(roomIn, Room3D))
            room3d = cast roomIn;
        
        for(comp in components) {
            comp.roomIn = roomIn;
        }

        this.roomIn = roomIn;
        return roomIn;
    }

    private function get_room(): Room {
        return roomIn;
    }

    private function set_parentOverride(parentOverride: h2d.Object): h2d.Object {
        // * Remove from previous parent
        layers.remove();

        this.parentOverride = parentOverride;

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

    public function new(?components: Array<Component>, ?position3d: Vec3, ?position2d: Vec2, layer: Int = 0) {
        if(components != null)
            addComponents(components);

        if(position3d != null)
            this.position = position.clone();
        else if(position2d != null)
            this.position = vec3(position2d, 0);  

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
        component.roomIn = roomIn;
        
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
            component.roomIn = roomIn;
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
                component.roomIn = null;
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

    @:allow(hcb.struct.Room.update)
    private function update(paused: Bool = false): Void {
        for(updateableComponent in updatableComponents) {
            if(!paused || Pause.updateOnPause(updateableComponent)) {
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
    public function getAllComponentsOfType<T>(t: Class<T>): Array<T> {
        var returnList: Array<T> = [];
        
        for(component in components) {
            if(Std.isOfType(component, t)) {
                returnList.push(cast component);
            }
        }
        return returnList;
    }

    // & Gets the first component of a particular type
    public function getComponentOfType<T>(t: Class<T>): T {
        for(component in components) {
            if(Std.isOfType(component, t)) {
                return cast component;
            }
        }
        return null;
    }

    // & Gets the entities position
    public function getPosition3d(): Vec3 {
        return position.clone();
    }

    public function getPosition2d(): Vec2 {
        return vec2(position);
    }

    // & Moves the position by a vector
    public function move(?moveVector3: Vec3, ?moveVector2: Vec2) {
        if(moveVector2 == null && moveVector3 == null)
            return;

        var moveVector: Vec3 = moveVector3 != null ? moveVector3 : vec3(moveVector2, 0);

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
    public function moveTo(?position3d: Vec3, ?position2d: Vec2, resetRemainder: Bool = true) {
        if(position2d == null && position3d == null)
            return;

        var position: Vec3 = position3d != null ? position3d.clone() : vec3(position2d, 0);
        var ev = onMoveEventCall.bind(_, this.position.clone());
        
        if(positionSnap) {
            if(resetRemainder)
                positionRemainder = position - position.floor();

            position = position.floor();
        }
        this.position = position;
        ev(position.clone());
    }

    // & Sets the position remainder
    public function setPosRemainder(remainder: Vec3) {
        positionRemainder = remainder.clone();
        if(Math.abs(positionRemainder.x) >= 1 || Math.abs(positionRemainder.y) >= 1 || Math.abs(positionRemainder.z) >= 1)
            move(vec3(0, 0, 0));
    }

    // & gets the position remainder
    public function getPosRemainder(): Vec3 { 
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
    public function onMoveEventSubscribe(callBack: (Vec3, Vec3) -> Void) {
        onMoveEventListeners.push(callBack);
    }

    public function onMoveEventRemove(callBack: (Vec3, Vec3) -> Void) {
        onMoveEventListeners.remove(callBack);
    }

    private function onMoveEventCall(to: Vec3, from: Vec3) {
        for(listener in onMoveEventListeners) {
            listener(to, from);
        }
    }
}