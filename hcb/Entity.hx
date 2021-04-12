package hcb;

import hcb.comp.Component;

class Entity {
    public var project: Project;
    private var components: Array<Component> = [];
    public var updatableComponents: Array<Component> = [];

    private var componentAddedEventListeners = new Array<Component -> Void>();
    private var componentRemovedEventListeners = new Array<Component -> Void>();

    public function new(project: Project) {
        this.project = project;
    }

    public function addComponent(component: Component, callInit: Bool = true): Void {
        
        if(component.parentEntity != null) {
            component.parentEntity.removeComponent(component);
        }

        components.push(component);
        if(component.updateable) {
            updatableComponents.push(component);
        }
        component.parentEntity = this;
        component.project = project;
        
        if(callInit) {
            component.init();
        }
        componentAddedEventCall(component);
    }

    public function removeComponent(component: Component): Void {
        if(components.contains(component)) {
            component.onDestroy();
            components.remove(component);
            if(updatableComponents.contains(component)) {
                updatableComponents.remove(component);
            }

            component.parentEntity = null;
            componentRemovedEventCall(component);
        }
        else {
            trace("Trying to remove component that does not exist.");
        }
    }

    public function destroy(): Void {
        if(project.entities.contains(this)) {
            project.entities.remove(this);
        }

        for(component in components) {
            component.onDestroy();
        }

        components = [];
        updatableComponents = [];
    }

    public function update(delta: Float): Void {
        for(updateableComponent in updatableComponents) {
            updateableComponent.update(delta);
        }
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
}