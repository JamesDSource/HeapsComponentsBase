package base.comp;

import base.math.Vector2;

class Navigation implements Component {
    public var parentEntity: Entity;
    public var updateable: Bool = false;
    public var name: String;

    public function init() {}
    public function update(delta: Float) {}
    public function onDestroy() {}

    public function new(name: String) {
        this.name = name;
    }

    public function getPathFrom(grid: PathfindingGrid, startPosition: Vector2, endPosition: Vector2): Array<Vector2> {
        var path: Array<Vector2> = grid.getPath(grid.getClosestPoint(startPosition), grid.getClosestPoint(endPosition));
        if(!path[path.length - 1].equals(endPosition)) {
            //path.push(endPosition);
        }
        return path;
    }

    public function getPathTo(grid: PathfindingGrid, targetPosition: Vector2): Array<Vector2> {
        if(parentEntity != null) {
            var transform: Transform2D = cast parentEntity.getSingleComponentOfType(Transform2D);
            if(transform != null) {
                return getPathFrom(grid, transform.position, targetPosition);
            }
        }
        return []; 
    }
}