package hcb.col;

import hcb.comp.col.*;
import hcb.comp.col.CollisionShape.Bounds;
import VectorMath;

using hcb.math.Vector;

typedef Raycast = {
    origin: Vec2,
    castTo: Vec2,
    // ^ Relative to the origin
    ?infinite: Bool
}

class Collisions {
    public static function test(shape1: CollisionShape, shape2: CollisionShape, ?manifold: Manifold): Bool {
        var result: Bool = false;
        
        if(!shape1.canInteractWith(shape2))
            return result;

        var flipped: Bool = false;
        switch(Type.getClass(shape1)) {
            case CollisionPolygon:
                switch(Type.getClass(shape2)) {
                    // Poly with poly
                    case CollisionPolygon:
                        result = polyWithPoly(cast shape1, cast shape2, manifold);
                    // Poly with circle
                    case CollisionCircle:
                        result = polyWithCircle(cast shape1, cast shape2, manifold);
                }
            case CollisionCircle:
                switch(Type.getClass(shape2)) {
                    // Circle with poly
                    case CollisionPolygon:
                        result = polyWithCircle(cast shape2, cast shape1, manifold);
                        flipped = true;
                    // Circle with circle
                    case CollisionCircle:
                        result = circleWithCircle(cast shape1, cast shape2, manifold);
                }
        }

        if(flipped && manifold != null && manifold.normal != null)
            manifold.normal *= -1;
        return result;
    }

    // Tests for an intersection with a ray, and returns the point of collision
    public extern overload static inline function raycastTest(raycast: Raycast, shape: CollisionShape): Vec2 {
        var result: Vec2 = null;
        
        if((raycast.infinite == null || !raycast.infinite) && !boundsIntersection(raycastBounds(raycast), shape.bounds))
            return result;

        switch(Type.getClass(shape)) {
            case CollisionPolygon:
                result = polyRaycast(cast shape, raycast);
            case CollisionCircle:
                var crCast = circleRaycast(cast shape, raycast);
                result = crCast != null ? crCast.closer : null;
        }

        return result;
    }

    // Tests for an intersection with a ray, and returns the point of collision
    public extern static overload inline function raycastTest(raycast: Raycast, bounds: Bounds): Vec2 {
        var rayPos = raycast.origin;
        var castPoint = rayPos + raycast.castTo;

        var intersectionPoint: Vec2 = null;

        // Checking if the ray origin is inside the AABB
        if(pointInAABB(rayPos, bounds))
            intersectionPoint = rayPos;
        else {
            // Get every vertex of the AABB to make lines with them
            var vertices: Array<Vec2> = [
                bounds.min,
                vec2(bounds.min.x, bounds.max.y),
                bounds.max,
                vec2(bounds.max.x, bounds.min.y)
            ];
            
            // Find all line intersection with the edges of the AABB and keep track of the closest
            var minDistance: Float = Math.POSITIVE_INFINITY;

            for(i in 0...vertices.length) {
                var vertex = vertices[i];
                var nextVertex = vertices[(i + 1)%vertices.length];

                var intersection = raycastTest({origin: vertex, castTo: nextVertex - vertex}, raycast);
                if(intersection != null) {
                    var d: Float = intersection.distance(raycast.origin);
                    if(d < minDistance) {
                        minDistance = d;
                        intersectionPoint = intersection;
                    }
                }
            }
        }

        return intersectionPoint;
    }

    // Tests for an intersection between two rays
    public extern overload static inline function raycastTest(raycast1: Raycast, raycast2: Raycast): Vec2 {
        // Calculating standard form of the lines
        var l1p1 = raycast1.origin,
            l1p2 = l1p1 + raycast1.castTo,
            l2p1 = raycast2.origin,
            l2p2 = l2p1 + raycast2.castTo,
            a1 = l1p2.y - l1p1.y,
            b1 = l1p1.x - l1p2.x,
            c1 = a1*l1p1.x + b1*l1p1.y,
            a2 = l2p2.y - l2p1.y,
            b2 = l2p1.x - l2p2.x,
            c2 = a2*l2p1.x + b2*l2p1.y;
        
        // Using the standard form to find the intersection point
        var denominator = a1*b2 - a2*b1;

        if(denominator == 0)
            return null;

        var x = (b2*c1 - b1*c2)/denominator,
            y = (a1*c2 - a2*c1)/denominator,
            p = vec2(x, y);
        
        var valid: Bool = pointInRayRange(p, raycast1) && pointInRayRange(p, raycast2);
        return valid ? p : null;
    }

    public static function pointTest(point: Vec2, shape: CollisionShape): Bool {
        switch(Type.getClass(shape)) {
            case CollisionPolygon:
                var poly: CollisionPolygon = cast(shape, CollisionPolygon);
                return pointInPolygon(point, poly.worldVertices);
            case CollisionCircle:
                var circle: CollisionCircle = cast(shape, CollisionCircle);
                return pointInCircle(point, circle.getAbsPosition(), circle.radius);
            default: 
                return false;
        }
    }

    // Checks for a collision between two polygons
    public static function polyWithPoly(polygon1: CollisionPolygon, polygon2: CollisionPolygon, ?manifold: Manifold): Bool {
        var polygon1Vertices = polygon1.worldVertices;
        var polygon2Vertices = polygon2.worldVertices;

        var isCollision: Bool = true;
        var minOverlap: Float = Math.POSITIVE_INFINITY;
        var smallestAxis: Vec2 = null;
        var contactPoints: Array<Vec2> = [];

        // Runs the code twice, switching which role each polygon plays both times
        for(i in 0...2) {
            var poly1V: Array<Vec2>;
            var poly2V: Array<Vec2>;
            
            if(i == 0) {
                poly1V = polygon1Vertices;
                poly2V = polygon2Vertices;
            }
            else {
                poly1V = polygon2Vertices;
                poly2V = polygon1Vertices;
            }

            for(j in 0...poly1V.length) {
                var vert: Vec2 = poly1V[j];
                var nextVert: Vec2 = poly1V[(j + 1)%poly1V.length];
                var axisProj: Vec2 = (nextVert - vert).crossRight().normalize();

                var interval1 = getInterval(poly1V, axisProj);
                var interval2 = getInterval(poly2V, axisProj);
                var overlap = overlapOnAxis(interval1, interval2);
                if(overlap < 0) {
                    if(manifold == null)
                        return false;

                    isCollision = false;
                    break;
                }

                // Getting the depth and seperation normal
                if(overlap < minOverlap) {
                    minOverlap = overlap;
                    smallestAxis = axisProj;
                    if((polygon1.center - polygon2.center).dot(smallestAxis) > 0)
                        smallestAxis *= -1;
                }
            }

            if(!isCollision) break;
        }

        // Filling the manifold
        if(manifold != null && smallestAxis != null) {
            manifold.normal = smallestAxis;
            manifold.penetration = minOverlap;
            manifold.contactPoints = getPolygonContactPoints(polygon1Vertices, polygon2Vertices, smallestAxis);
        }

        return isCollision;
    }

    // Checks for a collision between two circles
    public static function circleWithCircle(circle1: CollisionCircle, circle2: CollisionCircle, ?manifold: Manifold): Bool {
        var absPos1 = circle1.getAbsPosition(),
            absPos2 = circle2.getAbsPosition();

        var depth: Float = radiusIntersectionDepth(absPos1, absPos2, circle1.radius, circle2.radius);

        if(manifold == null)
            return depth >= 0;
        else {
            manifold.normal = (absPos2 - absPos1).normalize();
            manifold.penetration = depth;
            manifold.contactPoints = [absPos1 + manifold.normal*(circle1.radius - depth/2)];
            return depth >= 0;
        }
    }

    // Checks for a collision between a polygon and a circle
    public static function polyWithCircle(poly: CollisionPolygon, circle: CollisionCircle, ?manifold: Manifold): Bool {
        var circleCenter: Vec2 = circle.getAbsPosition();
        var verticies: Array<Vec2> = poly.worldVertices;

        // Find edge with minimun penetration
        var seperation: Float = Math.NEGATIVE_INFINITY;
        var v1: Vec2 = null, v2: Vec2 = null, faceNormal: Vec2 = null;
        for(i in 0...verticies.length) {
            var vertex: Vec2 = verticies[i];
            var nextVertex = verticies[(i + 1)%verticies.length];
            var edgeNormal: Vec2 = normalize(nextVertex - vertex).crossRight();

            var s = edgeNormal.dot(circleCenter - vertex);
            if(s > circle.radius)
                return false;

            if(s > seperation) {
                seperation = s;
                v1 = vertex;
                v2 = nextVertex;
                faceNormal = edgeNormal;
            }
        }

        if(manifold == null)
            return true;

        if(seperation < hxd.Math.EPSILON) {
            manifold.normal = faceNormal;
            manifold.penetration = circle.radius;
            manifold.contactPoints = [-faceNormal*circle.radius + circleCenter];
            return true;
        }

        // Voronoi regions
        var dot1: Float = dot(circleCenter - v1, v2 - v1);
        var dot2: Float = dot(circleCenter - v2, v1 - v2);
        manifold.penetration = circle.radius - seperation;

        if(dot1 <= 0) {
            manifold.normal = normalize(circleCenter - v1);
            manifold.contactPoints = [v1];
        }
        else if(dot2 <= 0) {
            manifold.normal = normalize(circleCenter - v2);
            manifold.contactPoints = [v2];
        }
        else {
            manifold.normal = faceNormal;
            manifold.contactPoints = [-faceNormal*circle.radius + circleCenter];
        }

        return true;
        /*
        var polyV = poly.worldVertices;
        var polyCenter = poly.center;
        var circleCenter = circle.getAbsPosition();
        var circleRadius = circle.radius;
        
        var closestVertexDistance: Float = Math.POSITIVE_INFINITY;
        var closestVertex: Vec2 = null;

        var closestEdge: {v1: Vec2, v2: Vec2} = null;
        var closestEdgeSeperation: Float = Math.NEGATIVE_INFINITY;
        
        var isCollision: Bool = true;

        var minOverlap: Float = Math.POSITIVE_INFINITY;
        var smallestAxis: Vec2 = vec2(0, 0);

        // First iteration checks the polygon
        for(i in 0...polyV.length) {
            var vert = polyV[i];
            var nextVert = polyV[(i + 1)%polyV.length];
            var axisProj: Vec2 =  (nextVert - vert).crossRight().normalize();

            // Getting the closest edge
            var s = axisProj.dot(circleCenter - polyCenter);
            if(s > closestEdgeSeperation) {
                closestEdgeSeperation = s;
                closestEdge = {
                    v1: vert,
                    v2: nextVert,
                }
            }
            
            // Getting the vetex closest to the center of the circle
            var vDistance = distance(vert, circleCenter);
            if(closestVertex == null || closestVertexDistance > vDistance) {
                closestVertexDistance = vDistance;
                closestVertex = vert;
            }

            var polyInterval = getInterval(polyV, axisProj);
            var circleInterval = getInterval([circleCenter - axisProj*circleRadius, circleCenter + axisProj*circleRadius], axisProj);
            var overlap: Float = overlapOnAxis(polyInterval, circleInterval);
            if(overlap < 0) {
                isCollision = false;
                break;
            }

            // Getting the depth and seperation normal
            if(overlap < minOverlap) {
                minOverlap = overlap;
                smallestAxis = axisProj.normalize();
                if((polyCenter - circleCenter).dot(smallestAxis) > 0)
                    smallestAxis *= -1;
            }
        }
        
        
        // Checking the axis between the closest vertex and the circle center
        var contactPoint: Vec2 = null;
        if(closestVertex == null) {
            isCollision = false;
        }
        else if(isCollision) { 
            var axisProj: Vec2 = (closestVertex - circleCenter).crossRight().normalize();
            var polyInterval = getInterval(polyV, axisProj);
            var circleInterval = getInterval([circleCenter - axisProj*circleRadius, circleCenter + axisProj*circleRadius], axisProj);
            var overlap: Float = overlapOnAxis(polyInterval, circleInterval);
            if(overlap < 0)
                isCollision = false;

            // Getting the depth and seperation normal
            if(overlap < minOverlap) {
                minOverlap = overlap;
                smallestAxis = axisProj.normalize();
                
                if((polyCenter - circleCenter).dot(smallestAxis) > 0) 
                    smallestAxis *= -1;
            }

            if(closestEdge != null) {
                var edge = closestEdge.v2 - closestEdge.v1;

                var d1 = edge.dot(closestEdge.v1);
                var d2 = edge.dot(closestEdge.v2);
                var c = edge.dot(circleCenter);

                c = hxd.Math.clamp((c - d1)/(d2 - d1), 0, 1);
                contactPoint = closestEdge.v1 + edge*c - smallestAxis*minOverlap/2;
            }
        }

        return {
            isColliding: isCollision,
            shape1: poly,
            shape2: circle,
            normal: smallestAxis,
            depth: minOverlap,
            contactPoints: contactPoint == null ? [closestEdge.v1, closestEdge.v2] : [contactPoint]
        };
        */
    }

    // Checks if two polygons overlap on a certain axis
    public static inline function overlapOnAxis(interval1: {max: Float, min: Float}, interval2: {max: Float, min: Float}): Float {
        return interval1.max < interval2.max ? interval1.max - interval2.min : interval2.max - interval1.min;
    }

    // Gets the interval of a polygon with a certain axis
    public static inline function getInterval(vertices: Array<Vec2>, axis: Vec2): {min: Float, max: Float} {
        var min = Math.POSITIVE_INFINITY;
        var max = Math.NEGATIVE_INFINITY;

        for(vert in vertices) {
            var projection: Float = axis.dot(vert);
            max = Math.max(max, projection);
            min = Math.min(min, projection);
        }

        return {min: min, max: max};
    }

    // Gets the contact points between two polygons
    public static function getPolygonContactPoints(vertices1: Array<Vec2>, vertices2: Array<Vec2>, sepAxis: Vec2): Array<Vec2> {
        var edge1 = getBestEdge(vertices1, sepAxis.normalize());
        var edge2 = getBestEdge(vertices2, -sepAxis.normalize());

        // Getting the ref and inc edge, the ref edge is more perpendicular to the seperation normal
        var refEdge: {max: Vec2, v1: Vec2, v2: Vec2, edge: Vec2};
        var incEdge: {max: Vec2, v1: Vec2, v2: Vec2, edge: Vec2};
        
        var edge1Dot = Math.abs(edge1.edge.dot(sepAxis));
        var edge2Dot = Math.abs(edge2.edge.dot(sepAxis));
        if(edge1Dot < edge2Dot || Math.abs(edge1Dot - edge2Dot) < 0.0001) {
            refEdge = edge1;
            incEdge = edge2;
        }
        else {
            refEdge = edge2;
            incEdge = edge1;
        }

        // Starting to clip
        var refV: Vec2 = refEdge.edge.normalize();
        var o1 = refV.dot(refEdge.v1);
        var clippedPoints = clip(incEdge.v1, incEdge.v2, refV, o1);

        // We need at least two points
        if(clippedPoints.length < 2) return []; 
        
        var o2: Float = refV.dot(refEdge.v2);
        clippedPoints = clip(clippedPoints[0], clippedPoints[1], -refV, -o2);
        
        // Once more, we need at least two points
        if(clippedPoints.length < 2) return [];
        
        // Ref edge normal for final clip
        var refNorm: Vec2 = refEdge.edge;
        refNorm = refNorm.crossRight();
        
        var max: Float = refNorm.dot(refEdge.max);
        var fPoint = clippedPoints[0];
        var sPoint = clippedPoints[1];
        
        if(refNorm.dot(fPoint) - max < 0)
            clippedPoints.remove(fPoint);
        
        if(refNorm.dot(sPoint) - max < 0)
            clippedPoints.remove(sPoint);
        
        return clippedPoints;
    }

    // Clips line segment points if they are past o along n
    private static inline function clip(v1: Vec2, v2: Vec2, n: Vec2, o: Float): Array<Vec2> {
        var points: Array<Vec2> = [];
        var d1: Float = n.dot(v1) - o;
        var d2: Float = n.dot(v2) - o;

        if(d1 >= 0.0) 
            points.push(v1);
        if(d2 >= 0.0) 
            points.push(v2);

        // Checking if they are on opposing sides
        if(d1*d2 < 0.0) {
            var e: Vec2 = v2 - v1;
            var u: Float = d1/(d1 - d2);
            e *= u;
            e += v1;

            points.push(e);
        }

        return points;
    }

    // Gets the best edge for finding collision points
    private static inline function getBestEdge(vertices: Array<Vec2>, normal: Vec2): {max: Vec2, v1: Vec2, v2: Vec2, edge: Vec2} {
        var maxProjection: Float = Math.NEGATIVE_INFINITY;
        var index: Int = -1;
        
        // Finding the index of the furthest point along the normal
        for(vert in vertices) {
            var projection = normal.dot(vert);
            if(projection > maxProjection) {
                maxProjection = projection;
                index = vertices.indexOf(vert);
            }
        }
        
        // Getting the edge that is the most perpendicular
        var maxVert: Vec2 = vertices[index];
        var v0 = vertices[(index + 1)%vertices.length];
        var v1 = vertices[index == 0 ? vertices.length - 1 : index - 1];
        var l: Vec2 = (maxVert - v1).normalize();
        var r: Vec2 = (maxVert - v0).normalize();
        
        if(r.dot(normal) <= l.dot(normal)) {
            return {
                max: maxVert,
                v1: v0,
                v2: maxVert,
                edge: maxVert - v0
            }
        }
        else {
            return {
                max: maxVert,
                v1: maxVert,
                v2: v1,
                edge: v1 - maxVert
            }
        }
    }

    // & Checks if two radiuses intersect
    public static inline function radiusIntersectionDepth(pos1: Vec2, pos2: Vec2, radius1: Float, radius2: Float): Float {
        var distance = (pos1 - pos2).length();
        return (radius1 + radius2) - distance;
    }

    public static inline function boundsIntersection(bounds1: Bounds, bounds2: Bounds): Bool {
        return  (bounds1.min.x <= bounds2.max.x &&
                 bounds1.max.x >= bounds2.min.x &&
                 bounds1.min.y <= bounds2.max.y &&
                 bounds1.max.y >= bounds2.min.y );
    }
    
    // & Finds the intersection point between a polygon and a ray
    public static inline function polyRaycast(poly: CollisionPolygon, ray: Raycast): Vec2 {    
        var vertices: Array<Vec2> = poly.worldVertices;
        var closestIntersection: Vec2 = null;
        var rayPos = ray.origin;

        if(pointInPolygon(rayPos, vertices)) {
            return rayPos;
        }

        for(i in 0...vertices.length) {
            var vertex1: Vec2 = vertices[i];
            var vertex2: Vec2 = vertices[(i + 1)%vertices.length];

            var intersection = raycastTest({origin: vertex1, castTo: vertex2 - vertex1}, ray);
            if(intersection != null && ( closestIntersection == null || (intersection - rayPos).length() < (closestIntersection - rayPos).length()))
                closestIntersection = intersection;
        }
        return closestIntersection;
    }

    // & Finds the intersection point between a circle and a ray
    public static inline function circleRaycast(circle: CollisionCircle, ray: Raycast): {closer: Vec2, ?further: Vec2} {
        // Fields
        var circlePos = circle.getAbsPosition(),
            radius = circle.radius,
            rayPos = ray.origin,
            castPoint = rayPos + ray.castTo,
            
            dx = castPoint.x - rayPos.x,
            dy = castPoint.y - rayPos.y,

            a = dx*dx + dy*dy,
            b = 2*(dx*(rayPos.x - circlePos.x) + dy*(rayPos.y - circlePos.y)),
            c = (rayPos.x - circlePos.x)*(rayPos.x - circlePos.x) + (rayPos.y - circlePos.y)*(rayPos.y - circlePos.y) - radius*radius,

            det = b*b -4*a*c;
        
        var intersectionPoints: {closer: Vec2, ?further: Vec2} = null;
        var realSolution: Bool = true;
        
        if(a <= 0.0000001 || det < 0) {
            // There are no real solutions
            realSolution = false;
        }
        else if(det == 0) {
            // There is one solution
            var t = -b/(2*a);
            intersectionPoints = {closer: vec2(rayPos.x + t*dx, rayPos.y + t*dy)};
        }
        else {
            // There are two solutions, we will return the solution closest to the
            // origin point of the ray
            var t = (-b + Math.sqrt(det))/(2*a);
            var intersection1 = vec2(rayPos.x + t*dx, rayPos.y + t*dy);

            t = (-b - Math.sqrt(det))/(2*a);
            var intersection2 = vec2(rayPos.x + t*dx, rayPos.y + t*dy);
            
            intersectionPoints = distance(intersection1, rayPos) < distance(intersection2, rayPos)
                                ? {closer: intersection1, further: intersection2} : {closer: intersection2, further: intersection1};
            
            if(!pointInRayRange(intersectionPoints.further, ray))
                intersectionPoints.further = null;
        }

        return (realSolution && pointInRayRange(intersectionPoints.closer, ray)) ? intersectionPoints : null;
    }

    // Checks if an intersection point is in the range of a raycast
    private static inline function pointInRayRange(point: Vec2, ray: Raycast): Bool {
        if(ray.infinite != null && ray.infinite)
            return (point - ray.origin).dot(ray.castTo) >= 0;
        
        var castPoint = ray.origin + ray.castTo,
            rx = (point.x - ray.origin.x) / (castPoint.x - ray.origin.x),
            ry = (point.y - ray.origin.y) / (castPoint.y - ray.origin.y);

        return (rx >= 0 && rx <= 1) || (ry >= 0 && ry <= 1);
    }

    // Gets the bounds of a raycast
    private static inline function raycastBounds(ray: Raycast): Bounds {
        var p1 = ray.origin;
        var p2 = p1 + ray.castTo;
        var bounds: Bounds = {
            min: vec2(Math.min(p2.x, p1.x) - 1, Math.min(p1.y, p2.y) - 1),
            max: vec2(Math.max(p2.x, p1.x) + 1, Math.max(p1.y, p2.y) + 1)
        };

        return bounds;
    }

    // Checks if a coordinite is inside a circle
    public static inline function pointInCircle(point: Vec2, circlePos: Vec2, radius: Float): Bool {
        return point.distance(circlePos) <= radius;
    }

    // Checks if a coordinite is inside an AABB
    public static inline function pointInAABB(point: Vec2, bounds: Bounds): Bool {
        return  point.x <= bounds.max.x    &&
                point.x >= bounds.min.x        &&
                point.y <= bounds.max.y    &&
                point.y >= bounds.min.y;
    }

    // Checks if a coordinite is inside a polygon
    public static inline function pointInPolygon(point: Vec2, vertices: Array<Vec2>): Bool {
        var result: Bool = false;
        
        if(vertices.length > 1) {
            var intersectionCount: Int = 0;
            for(i in 0...vertices.length) {
                var p1: Vec2 = vertices[i],
                    p2: Vec2 = vertices[(i + 1)%vertices.length];
                
                if(raycastTest({origin: p1, castTo: p2 - p1}, {origin: point, castTo: vec2(1, 0), infinite: true}) != null)
                    intersectionCount++;
            }
            result = intersectionCount%2 == 1;
        }

        return result;
    }

    /*
    // Checks if a coordinite is inside a triangle
    public static inline function pointInTriangle(a: Vec2, b: Vec2, c: Vec2, point: Vec2): Bool {
        var w1: Float = a.x*(c.y - a.y) + (point.y - a.y)*(c.x - a.x) - point.x*(c.y - a.y);
        w1 /= (b.y - a.y)*(c.x - a.x) - (b.x - a.x)*(c.y - a.y);

        var w2: Float = point.y - a.y - w1*(b.y - a.y);
        w2 /= c.y - a.y;

        return  w1 >= 0 && 
                w2 >= 0 && 
                (w1 + w2) <= 1;
    }
    */
}