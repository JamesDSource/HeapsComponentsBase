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
    private var polyRotation: Float = 0;
    private var polyScale: Vector2 = new Vector2(1, 1);

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
        polyRotation = degrees;
        updateTransformations();
    }

    public function getPolyRotation(): Float {
        return polyRotation;
    }

    public function setScale(scale: Vector2): Void {
        polyScale = scale;
        updateTransformations();
    }

    public function updateTransformations(): Void {
        transformedVerticies = [];
        for(vertex in verticies) {
            var tVertex = vertex.mult(polyScale);
            tVertex.setAngle(hxd.Math.degToRad(polyRotation) + vertex.getAngle());
            transformedVerticies.push(tVertex);
        }
    }

    public function setVerticies(verticies: Array<Vector2>) {
        this.verticies = verticies;
        updateTransformations();

        radius = 0.0;
        for(vertex in this.transformedVerticies) {
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