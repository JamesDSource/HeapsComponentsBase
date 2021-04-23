package hcb.comp.col;

import hcb.Origin.OriginPoint;
import hcb.comp.col.CollisionShape;
import VectorMath;

// TODO: Make rotation work
class CollisionPolygon extends CollisionShape {
    // ^ The points that define the polygon
    // * All vertices are relative to the x/y position
    private var vertices: Array<Vec2> = [];
    // ^ The points after scaling and rotation
    private var transformedVertices: Array<Vec2> = [];

    // ^ Transformation data
    // ^ Rotation is in degrees
    public var rotation(default, set): Float;
    public var scaleX(default, set): Float = 1;
    public var scaleY(default, set): Float = 1;
    private var polyScale: Vec2 = vec2(1, 1);

    // ^ Varuiables for saving the bounding data if the shape hasn't moved
    private var lastPos: Vec2 = null;
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
        if(shapeChanged || lastPos == null || lastBounds == null || pos != lastPos) {
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

            lastBounds = {min : vec2(pos.x + smX, pos.y + smY), max: vec2(pos.x + lgX, pos.y + lgY)};
            shapeChanged = false;
        }
        lastPos = pos.clone();

        return lastBounds;
    }

    public function new(name: String, vertices: Array<Vec2>, ?offset: Vec2) {
        super(name, offset);
        setVertices(vertices);
    }

    public function getVertices(): Array<Vec2> {
        var returnVertices: Array<Vec2> = [];
        for(vertex in vertices) {
            returnVertices.push(vertex.clone());
        }
        return returnVertices;
    }

    public function getTransformedVertices(): Array<Vec2> {
        var returnVertices: Array<Vec2> = [];
        for(vertex in transformedVertices) {
            returnVertices.push(vertex.clone());
        }
        return returnVertices;
    }

    public function getGlobalTransformedVertices(): Array<Vec2> {
        var returnVertices: Array<Vec2> = getTransformedVertices();
        var absPosition: Vec2 = getAbsPosition();
        if(absPosition == null) {
            return null;
        }
        
        for(vert in returnVertices) {
            vert += absPosition;
        }
        return returnVertices;
    }

    private function updateTransformations(): Void {
        transformedVertices = [];
        for(vertex in vertices) {
            var tVertex = vertex*polyScale;
            tVertex = hcb.math.Vector.vec2Angle(rotation + hcb.math.Vector.getAngle(tVertex), tVertex.length());
            transformedVertices.push(tVertex);
        }
        shapeChanged = true;
        updateCollisionCells();
    }

    public function setVertices(vertices: Array<Vec2>) {
        this.vertices = [];
        for(vert in vertices) {
            this.vertices.push(vert.clone());
        }
        updateTransformations();
    }

    public static function rectangle(name: String, width: Float, height: Float, origin: OriginPoint = OriginPoint.TopLeft) {
        var verts: Array<Vec2> = [
            vec2(0, 0),
            vec2(width - 1, 0),
            vec2(width - 1, height - 1),
            vec2(0, height - 1)
        ];

        var originOffset: Vec2 = Origin.getOriginOffset(origin, vec2(width, height));
        for(vert in verts) {
            vert += originOffset;
        }

        return new CollisionPolygon(name, verts);
    }
}