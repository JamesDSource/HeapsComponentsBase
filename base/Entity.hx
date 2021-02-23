package base;

import base.comp.Component;

class Entity {
    public var project: Project;
    private var components: Array<Component> = [];
    private var updatableComponents: Array<Component> = [];

    public function new(project: Project) {
        this.project = project;
    }

    public function addComponent(component: Component): Void {
        components.push(component);
        if(component.updateable) {
            updatableComponents.push(component);
        }
        component.parentEntity = this;
    }

    public function removeComponent(component: Component): Void {
        if(components.contains(component)) { 
            components.remove(component);
            if(updatableComponents.contains(component)) {
                updatableComponents.remove(component);
            }

            component.parentEntity = null;
        }
        else {
            trace("Trying to remove component that does not exist");
        }
    }

    public function update(delta: Float): Void {
        for(updateableComponent in updatableComponents) {
            updateableComponent.update(delta);
        }
    }

    public function getComponentsOfType(t: Dynamic): Array<Component> {
        var returnList: Array<Component> = [];
        
        for(component in components) {
            if(Std.isOfType(component, t)) {
                returnList.push(component);
            }
        }
        return returnList;
    }
}