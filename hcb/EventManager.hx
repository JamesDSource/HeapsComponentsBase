package hcb;

class EventManager {    
    public static var instance: EventManager = new EventManager();
    private function new() {}

    private var subsciptions = new Map<String, Array<Map<String, Dynamic> -> Void>>();

    public function eventSubscribe(name: String, callBack: Map<String, Dynamic> -> Void) {
        if(!subsciptions.exists(name)) {
            subsciptions[name] = new Array<Map<String, Dynamic> -> Void>();
        }

        subsciptions[name].push(callBack);
    }

    public function eventCall(name: String, arguments: Map<String, Dynamic>) {
        if(subsciptions.exists(name)) {
            for(subsciption in subsciptions[name]) {
                subsciption(arguments);
            }
        }
    }
}