package hcb.comp;

import VectorMath;

class Navigation extends Component {
    public function new(name: String) {
        super(name);
        updateable = false;
    }

    public function getPathFrom(grid: hcb.pathfinding.PathfindingGrid, startPosition: Vec2, endPosition: Vec2, addEnd: Bool = true): Array<Vec2> {
        var path: Array<Vec2> = grid.getPath(grid.getClosestCoord(startPosition), grid.getClosestCoord(endPosition), true);
        if(path.length > 0 && path[path.length - 1] != endPosition && addEnd) {
            path[path.length - 1] = endPosition;
        }
        return path;
    }

    public function getPathTo(grid: hcb.pathfinding.PathfindingGrid, targetPosition: Vec2, addEnd: Bool = true): Array<Vec2> {
        if(parentEntity != null) {
            return getPathFrom(grid, parentEntity.getPosition(), targetPosition, addEnd);
        }
        return []; 
    }
}