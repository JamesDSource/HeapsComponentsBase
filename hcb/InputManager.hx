package hcb;

import hxd.Key;

enum ActionInput {
    Pressed(key: Int);
    Released(key: Int);
    Down(key: Int);
}

class InputManager {

    private static var instance: InputManager = new InputManager();
    private function new() {}

    public static function get(): InputManager {
        return instance;
    }

    private var actions: Map<String, {inputs: Array<ActionInput>, result: Bool}> = [];
    private final actionDoesNotExist: String = "Trying to access an action that does not exist";

    public function addAction(name: String, ?inputs: Array<ActionInput>) {
        actions[name] = {
            inputs: inputs == null ? [] : inputs,
            result: false
        };
    }

    public function removeAction(name: String): Bool {
        return actions.remove(name);
    }

    public function isAction(name: String): Bool {
        return actions.exists(name);
    }

    public function addActionInput(action: String, input: ActionInput) {
        if(actions.exists(action)) {
            actions[action].inputs.push(input);
            return;
        }
        trace('$actionDoesNotExist: $action');
    }

    public function removeActionInput(action: String, input: ActionInput): Bool {
        if(actions.exists(action)) {
            return actions[action].inputs.remove(input);
        }
        trace('$actionDoesNotExist: $action');
        return false;
    }

    public function getActionResult(action: String): Bool {
        if(actions.exists(action)) {
            return actions[action].result;
        }
        trace('$actionDoesNotExist: $action');
        return false; 
    }

    @:allow(hcb.Room.update)
    private function catchInputs() {
        for(action in actions) {
            if(action.result)
                continue;

            for(input in action.inputs) {
                switch(input) {
                    case Pressed(key):
                        if(Key.isPressed(key)) {
                            action.result = true;
                            break;
                        }
                    case Released(key):
                        if(Key.isReleased(key)) {
                            action.result = true;
                            break;
                        }
                    case Down(key):
                        if(Key.isDown(key)) {
                            action.result = true;
                            break;
                        }
                }
            }
        }
    }

    @:allow(hcb.Room.update)
    private function clearInputs() {
        for(action in actions)
            action.result = false;
    }
}