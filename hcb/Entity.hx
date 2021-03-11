package hcb;

import hcb.comp.Component;

class Entity {
    public var project: Project;
    private var components: Array<Component> = [];
    public var updatableComponents: Array<Component> = [];

    public function new(project: Project) {
        this.project = project;
    }

    public function addComponent(component: Component, callInit: Bool = true): Void {
        components.push(component);
        if(component.updateable) {
            updatableComponents.push(component);
        }
        component.parentEntity = this;
        component.project = project;
        
        if(callInit) {
            component.init();
        }
    }

    public function removeComponent(component: Component): Void {
        if(components.contains(component)) {
            component.onDestroy();
            components.remove(component);
            if(updatableComponents.contains(component)) {
                updatableComponents.remove(component);
            }

            component.parentEntity = null;
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
    public function getComponentsOfType(t: Dynamic): Array<Component> {
        var returnList: Array<Component> = [];
        
        for(component in components) {
            if(Std.isOfType(component, t)) {
                returnList.push(component);
            }
        }
        return returnList;
    }

    // & Gets the first component of a particular type
    public function getSingleComponentOfType(t: Dynamic): Component {
        for(component in components) {
            if(Std.isOfType(component, t)) {
                return component;
            }
        }
        return null;
    }
}