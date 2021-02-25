package base.comp.col;

import base.comp.col.CollisionShape;
import base.math.Vector2;

// TODO: Make rotation work
class CollisionPolygon extends CollisionShape {
    // ^ The points that define the polygon
    // * All verticies are relative to the x/y position
    private var verticies: Array<Vector2> = [];
    // ^ The points after scaling and rotation
    private var transformedVerticies: Array<Vector2> = [];

    // ^ Transformation data
    private var polyRotation: Float = 0;

    public function new(name: String) {
        super(name);
    }

    public function getVerticies(): Array<Vector2> {
        var returnVerticies: Array<Vector2> = [];
        for(vertex in verticies) {
            returnVerticies.push(vertex.clone());
        }
        return returnVerticies;
    }

    public function getTransformedVerticies(): Array<Vector2> {
        var returnVerticies: Array<Vector2> = [];
        for(vertex in transformedVerticies) {
            returnVerticies.push(vertex.clone());
        }
        return returnVerticies;
    }

    public function getGlobalTransformedVerticies(): Array<Vector2> {
        var returnVerticies: Array<Vector2> = getTransformedVerticies();
        var absPosition: Vector2 = getAbsPosition();
        if(absPosition == null) {
            return null;
        }
        
        for(vert in returnVerticies) {
            vert.addMutate(absPosition);
        }
        return returnVerticies;
    }

    public function setPolyRotation(degrees: Float): Void {

    }

    public function setVerticies(verticies: Array<Vector2>) {
        this.verticies = verticies;
        transformedVerticies = verticies;

        radius = 0.0;
        for(vertex in this.verticies) {
            var len: Float = vertex.getLength();
            
            if(len > radius) {
                radius = Math.ceil(len);
            }

        }
    }

    public override function getBounds(): {topLeft: Vector2, bottomRight: Vector2} {
        var pos = getAbsPosition(),
            smX = Math.POSITIVE_INFINITY,
            smY = Math.POSITIVE_INFINITY,
            lgX = Math.NEGATIVE_INFINITY,
            lgY = Math.NEGATIVE_INFINITY;

        for(vertex in verticies) {
            if(vertex.x < smX) {
                smX = vertex.x;
            }
            if(vertex.x > lgX) {
                lgX = vertex.x;
            }
            if(vertex.y < smY) {
                smY = vertex.y;
            }
            if(vertex.y > lgY) {
                lgY = vertex.y;
            }
        }

        return {topLeft: new Vector2(pos.x + smX, pos.y + smY), bottomRight: new Vector2(pos.x + lgX, pos.y + lgY)};
    }
}