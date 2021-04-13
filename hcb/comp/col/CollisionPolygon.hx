package hcb.comp.col;

import hcb.Origin.OriginPoint;
import hcb.comp.col.CollisionShape;
import hcb.math.Vector2;

// TODO: Make rotation work
class CollisionPolygon extends CollisionShape {
    // ^ The points that define the polygon
    // * All vertices are relative to the x/y position
    private var vertices: Array<Vector2> = [];
    // ^ The points after scaling and rotation
    private var transformedVertices: Array<Vector2> = [];

    // ^ Transformation data
    // ^ Rotation is in degrees
    public var rotation(default, set): Float;
    public var scaleX(default, set): Float = 1;
    public var scaleY(default, set): Float = 1;
    private var polyScale: Vector2 = new Vector2(1, 1);

    // ^ Varuiables for saving the bounding data if the shape hasn't moved
    private var lastPos: Vector2 = null;
    private var lastBounds: Bounds = null;
    private var shapeChanged: Bool = false;

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

    private override function get_bounds(): Bounds {
        var pos = getAbsPosition();
        
        // * If the polygon has not changed position or shape from the last time get_bounds was called,
        // * it just returns the result from the last time
        if(shapeChanged || lastPos == null || lastBounds == null || !pos.equals(lastPos)) {
            var smX = Math.POSITIVE_INFINITY,
                smY = Math.POSITIVE_INFINITY,
                lgX = Math.NEGATIVE_INFINITY,
                lgY = Math.NEGATIVE_INFINITY;

            for(vertex in transformedVertices) {
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

            lastBounds = {min : new Vector2(pos.x + smX, pos.y + smY), max: new Vector2(pos.x + lgX, pos.y + lgY)};
            shapeChanged = false;
        }
        lastPos = pos.clone();

        return lastBounds;
    }

    public function new(name: String, vertices: Array<Vector2>) {
        super(name);
        setVertices(vertices);
    }

    public function getVertices(): Array<Vector2> {
        var returnVertices: Array<Vector2> = [];
        for(vertex in vertices) {
            returnVertices.push(vertex.clone());
        }
        return returnVertices;
    }

    public function getTransformedVertices(): Array<Vector2> {
        var returnVertices: Array<Vector2> = [];
        for(vertex in transformedVertices) {
            returnVertices.push(vertex.clone());
        }
        return returnVertices;
    }

    public function getGlobalTransformedVertices(): Array<Vector2> {
        var returnVertices: Array<Vector2> = getTransformedVertices();
        var absPosition: Vector2 = getAbsPosition();
        if(absPosition == null) {
            return null;
        }
        
        for(vert in returnVertices) {
            vert.addMutate(absPosition);
        }
        return returnVertices;
    }

    private function updateTransformations(): Void {
        transformedVertices = [];
        for(vertex in vertices) {
            var tVertex = vertex.mult(polyScale);
            tVertex.setAngle(hxd.Math.degToRad(rotation) + vertex.getAngle());
            transformedVertices.push(tVertex);
        }
        shapeChanged = true;
        updateCollisionCells();
    }

    public function setVertices(vertices: Array<Vector2>) {
        this.vertices = [];
        for(vert in vertices) {
            this.vertices.push(vert.clone());
        }
        updateTransformations();
    }

    public function rectangle(width: Float, height: Float, origin: OriginPoint = OriginPoint.topLeft) {
        var verts: Array<Vector2> = [
            new Vector2(0, 0),
            new Vector2(width - 1, 0),
            new Vector2(width - 1, height - 1),
            new Vector2(0, height - 1)
        ];

        var originOffset: Vector2 = Origin.getOriginOffset(origin, new Vector2(width, height));
        for(vert in verts) {
            vert.addMutate(originOffset);
        }

        this.vertices = verts;
        updateTransformations();
    }
}