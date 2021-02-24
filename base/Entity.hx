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
        component.init();
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

    // & Get's all components of the type you pass though, but you must cast it manually to an array of the type you want
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