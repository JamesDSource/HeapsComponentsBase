package hcb.comp.col;

import hcb.comp.col.CollisionShape;
import hcb.math.Vector2;

// TODO: Make rotation work
class CollisionPolygon extends CollisionShape {
    // ^ The points that define the polygon
    // * All verticies are relative to the x/y position
    private var verticies: Array<Vector2> = [];
    // ^ The points after scaling and rotation
    private var transformedVerticies: Array<Vector2> = [];

    // ^ Transformation data
    // ^ Rotation is in degrees
    public var rotation(default, set): Float;
    public var scaleX(default, set): Float = 1;
    public var scaleY(default, set): Float = 1;
    private var polyScale: Vector2 = new Vector2(1, 1);

    private function set_rotation(polyRotation: Float): Float {
        this.rotation = polyRotation;
        updateTransformations();
        return polyRotation;
    }

    private function set_scaleX(scaleX: Float): Float {
        this.scaleX = scaleX;
        polyScale.x = scaleX;
        updateTransformations();
        return scaleX;
    }

    private function set_scaleY(scaleY: Float): Float {
        this.scaleY = scaleY;
        polyScale.y = scaleY;
        updateTransformations();
        return scaleY;
    }

    public override function get_bounds(): Bounds {
        var pos = getAbsPosition(),
            smX = Math.POSITIVE_INFINITY,
            smY = Math.POSITIVE_INFINITY,
            lgX = Math.NEGATIVE_INFINITY,
            lgY = Math.NEGATIVE_INFINITY;

        for(vertex in transformedVerticies) {
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

        return {min : new Vector2(pos.x + smX, pos.y + smY), max: new Vector2(pos.x + lgX, pos.y + lgY)};
    }

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

    private function updateTransformations(): Void {
        transformedVerticies = [];
        for(vertex in verticies) {
            var tVertex = vertex.mult(polyScale);
            tVertex.setAngle(hxd.Math.degToRad(rotation) + vertex.getAngle());
            transformedVerticies.push(tVertex);
        }
    }

    public function setVerticies(verticies: Array<Vector2>) {
        this.verticies = verticies;
        updateTransformations();
    }
}