package hcb.comp;

import hcb.math.Vector2;

class Navigation extends Component {
    public function new(name: String) {
        super(name);
        updateable = false;
    }

    public function getPathFrom(grid: PathfindingGrid, startPosition: Vector2, endPosition: Vector2, addEnd: Bool = true): Array<Vector2> {
        var path: Array<Vector2> = grid.getPath(grid.getClosestPoint(startPosition), grid.getClosestPoint(endPosition));
        if(path.length > 0 && !path[path.length - 1].equals(endPosition) && addEnd) {
            path[path.length - 1] = endPosition;
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