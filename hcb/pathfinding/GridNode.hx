package hcb.pathfinding;

import VectorMath;

class GridNode extends Node {
    public var x(default, null): Int;
    public var y(default, null): Int;

    private var grid: Grid;

    public var diagCheckConnecting: Bool = true;

    public function new(x: Int, y: Int, grid: Grid, obsticle: Bool = false) {
        this.x = x;
        this.y = y;
        this.grid = grid;
        this.obsticle = obsticle;
    }

    public override function getConnecting():Array<Node> {
        var possibleSpaces: Array<Vec2> = [];
        var pos: Vec2 = vec2(x, y);
        if(diagCheckConnecting) {
            possibleSpaces = [
                vec2(pos.x + 1,  pos.y),     // * Right
                vec2(pos.x,      pos.y + 1), // * Down
                vec2(pos.x - 1,  pos.y),     // * Left
                vec2(pos.x,      pos.y - 1)  // * Up
            ];

            var rObs = grid.inRange(possibleSpaces[0]) ? grid.get(possibleSpaces[0]).obsticle : false,
                dObs = grid.inRange(possibleSpaces[1]) ? grid.get(possibleSpaces[1]).obsticle : false,
                lObs = grid.inRange(possibleSpaces[2]) ? grid.get(possibleSpaces[2]).obsticle : false,
                uObs = grid.inRange(possibleSpaces[3]) ? grid.get(possibleSpaces[3]).obsticle : false;

            if(!rObs && !dObs) {  // * Right Down
                possibleSpaces.push(vec2(pos.x + 1, pos.y + 1));
            }
            if(!lObs && !dObs) {  // * Left Down
                possibleSpaces.push(vec2(pos.x - 1, pos.y + 1));
            }
            if(!rObs && !uObs) {  // * Right up
                possibleSpaces.push(vec2(pos.x + 1, pos.y - 1));
            }
            if(!lObs && !uObs) {  // * Left up
                possibleSpaces.push(vec2(pos.x - 1, pos.y - 1));
            }
        }
        else {
            possibleSpaces = [
                vec2(pos.x + 1,  pos.y),      // * Right    
                vec2(pos.x,      pos.y + 1),  // * Down
                vec2(pos.x - 1,  pos.y),      // * Left
                vec2(pos.x,      pos.y - 1),  // * Up
                vec2(pos.x + 1,  pos.y + 1),  // * Right down
                vec2(pos.x - 1,  pos.y + 1),  // * Left down
                vec2(pos.x + 1,  pos.y - 1),  // * Right up
                vec2(pos.x - 1,  pos.y - 1)   // * Left up
            ];
        }

        var returnArray: Array<Node> = [];
        for(possibleSpace in possibleSpaces) {
            if(grid.inRange(possibleSpace))
                returnArray.push(grid.get(possibleSpace));
        }

        return returnArray;
    }

    public override function getDistance(node: Node):Int {
        if(!Std.isOfType(node, GridNode))
            return 0;

        var node2: GridNode = cast(node, GridNode);

        var distX: Int = Std.int(Math.abs(x - node2.x)),
            distY: Int = Std.int(Math.abs(y - node2.y));
        
        if(distX < distY) 
            return Std.int(14*distX + 10*(distY - distX));
        else
            return Std.int(14*distY + 10*(distX - distY));
    }
}