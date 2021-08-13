package hcb.comp.col;

import h2d.Graphics;
import hcb.Origin.OriginPoint;
import hcb.comp.col.CollisionShape;
import VectorMath;

using hcb.math.Vector;

// TODO: Make rotation work
class CollisionPolygon extends CollisionShape {
    //  All vertices are relative to the x/y position
    private var vertices: Array<Vec2> = [];
    // ^ The points that define the polygon
    private var transformedVertices: Array<Vec2> = [];
    // ^ The points after scaling and rotation

    public var localVertices(get, null): Array<Vec2>;
    public var transLocalVertices(get, null): Array<Vec2>;
    public var worldVertices(get, null): Array<Vec2>;
    // ^ Properties only used to get the vertices, cannot be used to modify the polygon shape

    private var lastPos: Vec2 = null;
    private var lastBounds: Bounds = null;
    private var shapeChanged: Bool = false;
    // ^ Varuiables for saving the bounding data if the shape hasn't moved

    private inline function get_localVertices(): Array<Vec2> {
        return vertices.map((vert) -> vert.clone());
    }

    private inline function get_transLocalVertices(): Array<Vec2> {
        return transformedVertices.map((vert) -> vert.clone());
    }

    private inline function get_worldVertices(): Array<Vec2> {
        var position: Vec2 = transform.getPosition();
        return transformedVertices.map((vert) -> vert + position);
    }

    private override function get_bounds(): Bounds {
        var pos = transform.getPosition();
        
        // If the polygon has not changed position or shape from the last time get_bounds was called,
        // it just returns the result from the last time
        if(shapeChanged || lastPos == null || lastBounds == null || pos != lastPos) {
            var smX = Math.POSITIVE_INFINITY,
                smY = Math.POSITIVE_INFINITY,
                lgX = Math.NEGATIVE_INFINITY,
                lgY = Math.NEGATIVE_INFINITY;

            for(vertex in transformedVertices) {
                smX = Math.min(smX, vertex.x);
                lgX = Math.max(lgX, vertex.x);
                smY = Math.min(smY, vertex.y);
                lgY = Math.max(lgY, vertex.y);
            }

            lastBounds = {min : vec2(pos.x + smX, pos.y + smY), max: vec2(pos.x + lgX, pos.y + lgY)};
            shapeChanged = false;
        }
        lastPos = pos;

        return lastBounds;
    }

    private override function get_center(): Vec2 {
        var center: Vec2 = vec2(0, 0);

        for(vert in worldVertices) {
            center += vert;
        }
        center /= vertices.length;

        return center;
    }

    public function new(vertices: Array<Vec2>, forceCCW: Bool = true, name: String = "Collision Polygon") {
        super(name);
        setVertices(vertices, forceCCW);
        transform.onRotated = (r) -> updateTransformations();
    }

    private function updateTransformations(): Void {
        transformedVertices = [];
        for(vertex in vertices) {
            var tVertex = vertex*transform.getScale();
            tVertex.setAngle(transform.getRotationRad() + tVertex.getAngle());
            transformedVertices.push(tVertex);
        }
        shapeChanged = true;
        updateCollisionCells();
    }

    // & Sets the verticies on the polygon relative to the origin. KeepWindingCCW will make sure that the
    // & the points are winding counter clockwise if set to true
    public function setVertices(vertices: Array<Vec2>, forceCCW: Bool = true) {
        if(vertices.length < 2)
            throw "Need at least two vertices in a CollisionPolygon";
        
        this.vertices = [];
        var signedAreaSum: Float = 0;
        for(i in 0...vertices.length) {
            var vert = vertices[i];
            var nextVert = vertices[(i + 1)%vertices.length];

            signedAreaSum += vert.x*nextVert.y - nextVert.x*vert.y;
            this.vertices.push(vert.clone());
        }

        if(signedAreaSum > 0 && forceCCW) 
            this.vertices.reverse();
        
        updateTransformations();
    }

    public override function getSupportPoint(d:Vec2):Vec2 {
        var max: Float = Math.NEGATIVE_INFINITY;
        var point: Vec2 = null;
        for(vertex in worldVertices) {
            var dot = d.dot(vertex);
            if(dot > max) {
                max = dot;
                point = vertex;
            }
        }

        return point;
    }

    public override function represent(g:Graphics, ?color: Int, alpha: Float = 1.) {
        super.represent(g, color, alpha);
        var vertices: Array<Vec2> = worldVertices;
        for(i in 0...vertices.length) {
            var vert = vertices[i];
            var nextVert = vertices[(i + 1)%vertices.length];
            g.moveTo(vert.x, vert.y);
            g.lineTo(nextVert.x, nextVert.y);

            var dif = nextVert - vert;
            var difN = dif.normalize();
            var pos = vert + difN*dif.length()/2;
            g.moveTo(pos.x, pos.y);
            pos += difN.crossRight()*2;
            g.lineTo(pos.x, pos.y);
        }
    }

    public static function rectangle(width: Float, height: Float, origin: OriginPoint = OriginPoint.TopLeft, name: String = "Collision Polygon") {
        var verts: Array<Vec2> = [
            vec2(0, 0),
            vec2(0, height),
            vec2(width, height),
            vec2(width, 0)
        ];

        if(origin != OriginPoint.TopLeft) {
            var originOffset: Vec2 = Origin.getOriginOffset(origin, vec2(width, height));
            for(vert in verts) {
                vert += originOffset;
            }
        }

        return new CollisionPolygon(verts, name);
    }
}