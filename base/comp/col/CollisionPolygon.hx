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
}