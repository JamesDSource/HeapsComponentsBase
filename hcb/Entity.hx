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

    private inline function get_room(): Room {
        return roomIn;
    }

    public function new(?components: Array<Component>) {
        if(components != null)
            addComponents(components); 
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
        for(comp in components.copy())
            removeComponent(comp);
    }

    public function remove() {
        if(room != null && room.hasEntity(this))
            room.removeEntity(this);
    }

    @:allow(hcb.struct.Room.update)
    private function update(paused: Bool = false): Void {
        for(updateableComponent in updatableComponents) {
            if(!paused || Pause.updateOnPause(updateableComponent))
                updateableComponent.update();
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

    // & Component added event
    public function componentAddedEventSubscribe(callBack: Component -> Void) {
        componentAddedEventListeners.push(callBack);
    }

    public function componentAddedEventRemove(callBack: Component -> Void) {
        componentAddedEventListeners.remove(callBack);
    }

    private function componentAddedEventCall(component: Component) {
        for(listener in componentAddedEventListeners)
            listener(component);
    }

    // & Component removed event
    public function componentRemovedEventSubscribe(callBack: Component -> Void) {
        componentRemovedEventListeners.push(callBack);
    }

    public function componentRemovedEventRemove(callBack: Component -> Void) {
        componentRemovedEventListeners.remove(callBack);
    }

    private function componentRemovedEventCall(component: Component) {
        for(listener in componentRemovedEventListeners)
            listener(component);
    }
}