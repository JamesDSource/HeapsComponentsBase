package hcb.col;

import hcb.math.Vector;
import hcb.comp.col.*;
import hcb.comp.col.CollisionShape.Bounds;
import VectorMath;


typedef CollisionInfo = {
    isColliding: Bool,
    shape1: CollisionShape,
    shape2: CollisionShape,
    normal: Vec2,
    depth: Float,
    contactPoints: Array<Vec2>
}

typedef Raycast = {
    origin: Vec2,
    castTo: Vec2,
    // ^ Relative to the origin
    infinite: Bool
}

class Collisions {
    public static function test(shape1: CollisionShape, shape2: CollisionShape): CollisionInfo {
        var result: CollisionInfo = {
            isColliding: false,
            shape1: null,
            shape2: null,
            normal: null,
            depth: 0,
            contactPoints: []
        }
        
        if(!shape1.canInteractWith(shape2))
            return result;

        var flipped: Bool = false;
        switch(Type.getClass(shape1)) {
            case CollisionAABB:
                switch(Type.getClass(shape2)) {
                    // * AABB with AABB
                    case CollisionAABB:
                        result = aabbWithAabb(cast shape1, cast shape2);
                    // * AABB with poly
                    case CollisionPolygon:
                        result = aabbWithPoly(cast shape1, cast shape2);
                    // * AABB with circle
                    case CollisionCircle:
                        result = aabbWithCircle(cast shape1, cast shape2);
                }
            case CollisionPolygon:
                switch(Type.getClass(shape2)) {
                    // * poly with AABB
                    case CollisionAABB:
                        result = aabbWithPoly(cast shape2, cast shape1);
                        flipped = true;
                    // * Poly with poly
                    case CollisionPolygon:
                        result = polyWithPoly(cast shape1, cast shape2);
                    // * Poly with circle
                    case CollisionCircle:
                        result = polyWithCircle(cast shape1, cast shape2);
                }
            case CollisionCircle:
                switch(Type.getClass(shape2)) {
                    // * Circle with AABB
                    case CollisionAABB:
                        result = aabbWithCircle(cast shape2, cast shape1);
                        flipped = true;
                    // * Circle with poly
                    case CollisionPolygon:
                        result = polyWithCircle(cast shape2, cast shape1);
                        flipped = true;
                    // * Circle with circle
                    case CollisionCircle:
                        result = circleWithCircle(cast shape1, cast shape2);
                }
        }

        result.shape1 = shape1;
        result.shape2 = shape2;
        if(flipped && result.normal != null) {
            result.normal *= -1;
        }
        return result;
    }

    // & Tests for an intersection with a ray, and returns the point of collision
    public extern overload static inline function raycastTest(raycast: Raycast, shape: CollisionShape): Vec2 {
        var result: Vec2 = null;
        
        var p1 = raycast.origin;
        var p2 = p1 + raycast.castTo;
        var bounds: Bounds = {
            min: vec2(Math.min(p2.x, p1.x) - 1, Math.min(p1.y, p2.y) - 1),
            max: vec2(Math.max(p2.x, p1.x) + 1, Math.max(p1.y, p2.y) + 1)
        };

        if(!boundsIntersection(bounds, shape.bounds))
            return result;

        switch(Type.getClass(shape)) {
            case CollisionAABB:
                result = aabbRaycast(cast shape, raycast);
            case CollisionPolygon:
                result = polyRaycast(cast shape, raycast);
            case CollisionCircle:
                result = circleRaycast(cast shape, raycast);
        }

        return result;
    }

    // & Tests for an intersection between two rays
    public extern overload static inline function raycastTest(raycast1: Raycast, raycast2: Raycast): Vec2 {
        return lineIntersection(
            raycast1.origin, 
            raycast1.origin + raycast1.castTo, 
            raycast1.infinite,
            raycast2.origin,
            raycast2.origin + raycast2.castTo,
            raycast2.infinite
        );
    }

    public static function pointTest(point: Vec2, shape: CollisionShape): Bool {
        switch(Type.getClass(shape)) {
            case CollisionAABB:
                var bounds = shape.bounds;
                return pointInAABB(point, bounds.min, bounds.max);
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

    // & Checks for a collision between two AABBs
    public static inline function aabbWithAabb(aabb1: CollisionAABB, aabb2: CollisionAABB): CollisionInfo {
        var verts1 = aabb1.vertices;
        var verts2 = aabb2.vertices;

        var isColliding = boundsIntersection(aabb1.bounds, aabb2.bounds);
        var minOverlap: Float = Math.POSITIVE_INFINITY;
        var smallestAxis: Vec2 = null;
        var contactPoints: Array<Vec2> = [];

        if(isColliding) {
            var checkAxis: Array<Vec2> = [
                vec2(1, 0),
                vec2(0, 1)
            ];

            for(axis in checkAxis) {
                var interval1 = getInterval(verts1, axis);
                var interval2 = getInterval(verts2, axis);
                var overlap = overlapOnAxis(interval1, interval2);
                
                // * Getting the depth and seperation normal
                if(overlap < minOverlap) {
                    minOverlap = overlap;
                    smallestAxis = axis.normalize();
                    if((aabb1.center - aabb2.center).dot(smallestAxis) > 0) {
                        smallestAxis *= -1;
                    }
                }
            }

            if(smallestAxis != null) {
                contactPoints = getPolygonContactPoints(verts1, verts2, smallestAxis);
            }
        }

        
        
        return {
            isColliding: isColliding,
            shape1: aabb1,
            shape2: aabb2,
            normal: smallestAxis,
            depth: minOverlap,
            contactPoints: contactPoints
        }
    }

    // & Checks for a collision between two polygons
    public static inline function polyWithPoly(polygon1: CollisionPolygon, polygon2: CollisionPolygon): CollisionInfo {
        var polygon1Vertices = polygon1.worldVertices;
        var polygon2Vertices = polygon2.worldVertices;

        var isCollision: Bool = true;
        var minOverlap: Float = Math.POSITIVE_INFINITY;
        var smallestAxis: Vec2 = null;
        var contactPoints: Array<Vec2> = [];

        // * Runs the code twice, switching which role each polygon plays both times
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
                var axisProj: Vec2 = new Vec2(-(vert.y - nextVert.y), vert.x - nextVert.x).normalize();

                var interval1 = getInterval(poly1V, axisProj);
                var interval2 = getInterval(poly2V, axisProj);
                var overlap = overlapOnAxis(interval1, interval2);
                if(overlap < 0) {
                    isCollision = false;
                    break;
                }

                // * Getting the depth and seperation normal
                if(overlap < minOverlap) {
                    minOverlap = overlap;
                    smallestAxis = axisProj.normalize();
                    if((polygon1.center - polygon2.center).dot(smallestAxis) > 0) {
                        smallestAxis *= -1;
                    }
                }
            }

            if(!isCollision) break;
        }

        // * USing the clipping method to get the contact points
        if(isCollision && smallestAxis != null) {
            contactPoints = getPolygonContactPoints(polygon1Vertices, polygon2Vertices, smallestAxis);
        }

        return {
            isColliding: isCollision,
            shape1: polygon1,
            shape2: polygon2,
            depth: minOverlap,
            normal: smallestAxis,
            contactPoints: contactPoints
        };
    }

    // & Checks for a collision between two circles
    public static inline function circleWithCircle(circle1: CollisionCircle, circle2: CollisionCircle): CollisionInfo {
        var absPos1 = circle1.getAbsPosition(),
            absPos2 = circle2.getAbsPosition();

        var depth: Float = radiusIntersectionDepth(absPos1, absPos2, circle1.radius, circle2.radius),
            normal: Vec2 = (absPos2 - absPos1).normalize();

        return {
            isColliding: depth < 0,
            shape1: circle1,
            shape2: circle2,
            normal: normal,
            depth: depth,
            contactPoints:  [absPos1 + normal*(circle1.radius - depth/2)]
        }
    }

    // & Checks for a collision between a polygon and a circle
    public static inline function polyWithCircle(poly: CollisionPolygon, circle: CollisionCircle): CollisionInfo {
        var polyV = poly.worldVertices;
        var circleCenter = circle.getAbsPosition();
        var circleRadius = circle.radius;
        var closestVertex: Vec2 = null;
        var isCollision: Bool = true;

        var minOverlap: Float = Math.POSITIVE_INFINITY;
        var smallestAxis: Vec2 = vec2(0, 0);

        // * First iteration checks the polygon
        for(i in 0...polyV.length) {
            var vert = polyV[i];
            var nextVert = polyV[(i + 1)%polyV.length];
            var axisProj: Vec2 =  vec2(-(vert.y - nextVert.y), vert.x - nextVert.x).normalize();
            
            // * Getting the vetex closest to the center of the circle
            if(closestVertex == null || distance(closestVertex, circleCenter) > distance(vert, circleCenter)) {
                closestVertex = vert;
            }
            var polyInterval = getInterval(polyV, axisProj);
            var circleInterval = getInterval([circleCenter - axisProj*circleRadius, circleCenter + axisProj*circleRadius], axisProj);
            var overlap: Float = overlapOnAxis(polyInterval, circleInterval);
            if(overlap < 0) {
                isCollision = false;
                break;
            }
            // * Getting the depth and seperation normal
            if(overlap < minOverlap) {
                minOverlap = overlap;
                smallestAxis = axisProj.normalize();
                if((poly.center - circleCenter).dot(smallestAxis) > 0) {
                    smallestAxis *= -1;
                }
            }
        }
        // * Checking the axis between the closest vertex and the circle center
        if(closestVertex == null) {
            isCollision = false;
        }
        else if(isCollision) { 
            var axisProj: Vec2 = vec2(-(closestVertex.y - circleCenter.y), closestVertex.x - circleCenter.x).normalize();
            var polyInterval = getInterval(polyV, axisProj);
            var circleInterval = getInterval([circleCenter - axisProj*circleRadius, circleCenter + axisProj*circleRadius], axisProj);
            var overlap: Float = overlapOnAxis(polyInterval, circleInterval);
            if(overlap < 0) {
                isCollision = false;
            }
            // * Getting the depth and seperation normal
            if(overlap < minOverlap) {
                minOverlap = overlap;
                smallestAxis = axisProj.normalize();
                if((poly.center - circleCenter).dot(smallestAxis) > 0) {
                    smallestAxis *= -1;
                }
            }
        }

        return {
            isColliding: isCollision,
            shape1: poly,
            shape2: circle,
            normal: smallestAxis,
            depth: minOverlap,
            contactPoints: [circleCenter - smallestAxis*(minOverlap/2 + circleRadius)]
        };
    }

    // & Checks for a collision between an AABB and a polygon
    public static inline function aabbWithPoly(aabb: CollisionAABB, poly: CollisionPolygon): CollisionInfo {
        var isCollision: Bool = true;
        var minOverlap: Float = Math.POSITIVE_INFINITY;
        var smallestAxis: Vec2 = null;

        // * Runs the code twice, switching between checking the poly to the AABB
        var aabbVerts: Array<Vec2> = aabb.vertices;
        var polyVerts: Array<Vec2> = poly.worldVertices;
        for(i in 0...2) {
            var poly1V: Array<Vec2> = [];
            var poly2V: Array<Vec2> = [];
            if(i == 0) {
                poly1V = polyVerts;
                poly2V = aabbVerts;
            }
            else {
                poly1V = aabbVerts;
                poly2V = polyVerts;
            }

            
            for(j in 0...poly1V.length) {
                var vert: Vec2 = poly1V[j];
                var nextVert: Vec2 = poly1V[(j + 1)%poly1V.length];
                var axisProj: Vec2 = vec2(-(vert.y - nextVert.y), vert.x - nextVert.x).normalize();

                var interval1 = getInterval(poly1V, axisProj);
                var interval2 = getInterval(poly2V, axisProj);
                var overlap: Float = overlapOnAxis(interval1, interval2);
                if(overlap < 0) {
                    isCollision = false;
                    break;
                }

                // * Getting the depth and seperation normal
                if(overlap < minOverlap) {
                    minOverlap = overlap;
                    smallestAxis = axisProj.normalize();
                    if((aabb.center - poly.center).dot(smallestAxis) > 0) {
                        smallestAxis *= -1;
                    }
                }
            }

            if(!isCollision) break;
        }

        var contactPoints: Array<Vec2> = [];
        if(isCollision && smallestAxis != null) {
            contactPoints = getPolygonContactPoints(aabbVerts, polyVerts, smallestAxis);
        }

        return {
            isColliding: isCollision,
            shape1: aabb,
            shape2: poly,
            normal: smallestAxis,
            depth: minOverlap ,
            contactPoints: contactPoints
        };
    }

    // & Checks for a collision between an AABB and a circle
    public static inline function aabbWithCircle(aabb: CollisionAABB, circle: CollisionCircle): CollisionInfo {
        var vertices = aabb.vertices;
        var circleCenter = circle.getAbsPosition();
        var circleRadius = circle.radius;
        var isCollision: Bool = true;

        var minOverlap: Float = Math.POSITIVE_INFINITY;
        var smallestAxis: Vec2 = vec2(0, 0);

        var axes: Array<Vec2> = [
            vec2(1, 0),
            vec2(0, 1)
        ];

        // * First iteration checks the aabb
        for(axisProj in axes) {
            var polyInterval = getInterval(vertices, axisProj);
            var circleInterval = getInterval([circleCenter - axisProj*circleRadius, circleCenter + axisProj*circleRadius], axisProj);
            var overlap: Float = overlapOnAxis(polyInterval, circleInterval);
            if(overlap < 0) {
                isCollision = false;
                break;
            }
            // * Getting the depth and seperation normal
            if(overlap < minOverlap) {
                minOverlap = overlap;
                smallestAxis = axisProj.normalize();
                if((aabb.center - circleCenter).dot(smallestAxis) > 0) {
                    smallestAxis *= -1;
                }
            }
        }
        // * Checking the axis between the closest vertex and the circle center
        if(isCollision) { 
            // * Getting the vetex closest to the center of the circle
            var closestVertex: Vec2 = null;
            for(vertex in vertices) {
                if(closestVertex == null || distance(closestVertex, circleCenter) > distance(vertex, circleCenter)) {
                    closestVertex = vertex;
                }
            }

            var axisProj: Vec2 = vec2(-(closestVertex.y - circleCenter.y), closestVertex.x - circleCenter.x).normalize();
            var polyInterval = getInterval(vertices, axisProj);
            var circleInterval = getInterval([circleCenter - axisProj*circleRadius, circleCenter + axisProj*circleRadius], axisProj);
            var overlap: Float = overlapOnAxis(polyInterval, circleInterval);
            if(overlap < 0) {
                isCollision = false;
            }
            // * Getting the depth and seperation normal
            if(overlap < minOverlap) {
                minOverlap = overlap;
                smallestAxis = axisProj.normalize();
                if((aabb.center - circleCenter).dot(smallestAxis) > 0) {
                    smallestAxis *= -1;
                }
            }
        }

        return {
            isColliding: isCollision,
            shape1: aabb,
            shape2: circle,
            normal: smallestAxis,
            depth: minOverlap,
            contactPoints: [circleCenter - smallestAxis*(minOverlap/2 + circleRadius)]
        };
    }

    // & Checks if two polygons overlap on a certain axis
    public static inline function overlapOnAxis(interval1: {max: Float, min: Float}, interval2: {max: Float, min: Float}): Float {
        return Math.min(interval1.max, interval2.max) - Math.max(interval1.min, interval2.min);
    }

    // & Gets the interval of a polygon with a certain axis
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

    // & Gets the contact points between two polygons
    public static function getPolygonContactPoints(vertices1: Array<Vec2>, vertices2: Array<Vec2>, sepAxis: Vec2): Array<Vec2> {
        var edge1 = getBestEdge(vertices1, sepAxis.normalize());
        var edge2 = getBestEdge(vertices2, -sepAxis.normalize());

        // * Getting the ref and inc edge, the ref edge is more perpendicular to the seperation normal
        var refEdge: {max: Vec2, v1: Vec2, v2: Vec2, edge: Vec2};
        var incEdge: {max: Vec2, v1: Vec2, v2: Vec2, edge: Vec2};
        var flip: Bool = false;
        // ^ Indicating that the ref and inc edge are flipped
        
        var edge1Dot = Math.abs(edge1.edge.dot(sepAxis));
        var edge2Dot = Math.abs(edge2.edge.dot(sepAxis));
        if(edge1Dot < edge2Dot || Math.abs(edge1Dot - edge2Dot) < 0.0001) {
            refEdge = edge1;
            incEdge = edge2;
            flip = true;
        }
        else {
            refEdge = edge2;
            incEdge = edge1;
        }

        // * Starting to clip
        var refV: Vec2 = refEdge.edge.normalize();
        var o1 = refV.dot(refEdge.v1);
        var clippedPoints = clip(incEdge.v1, incEdge.v2, refV, o1);

        // * We need at least two points
        if(clippedPoints.length < 2) return []; 
        
        var o2: Float = refV.dot(refEdge.v2);
        clippedPoints = clip(clippedPoints[0], clippedPoints[1], -refV, -o2);
        
        // * Once more, we need at least two points
        if(clippedPoints.length < 2) return [];
        
        // * Ref edge normal for final clip
        var refNorm: Vec2 = refEdge.edge;
        refNorm = Vector.cross(refNorm, -1);
        //if(flip) refNorm *= -1;
        
        var max: Float = refNorm.dot(refEdge.max);
        var fPoint = clippedPoints[0];
        var sPoint = clippedPoints[1];
        
        if(refNorm.dot(fPoint) - max < 0) {
            clippedPoints.remove(fPoint);
        }
        
        if(refNorm.dot(sPoint) - max < 0) {
            clippedPoints.remove(sPoint);
        }
        
        return clippedPoints;
    }

    // & Clips line segment points if they are past o along n
    private static inline function clip(v1: Vec2, v2: Vec2, n: Vec2, o: Float): Array<Vec2> {
        var points: Array<Vec2> = [];
        var d1: Float = n.dot(v1) - o;
        var d2: Float = n.dot(v2) - o;

        if(d1 >= 0.0) points.push(v1);
        if(d2 >= 0.0) points.push(v2);

        // * Checking if they are on opposing sides
        if(d1*d2 < 0.0) {
            var e: Vec2 = v2 - v1;
            var u: Float = d1/(d1 - d2);
            e *= u;
            e += v1;

            points.push(e);
        }

        return points;
    }

    // & Gets the best edge for finding collision points
    private static inline function getBestEdge(vertices: Array<Vec2>, normal: Vec2): {max: Vec2, v1: Vec2, v2: Vec2, edge: Vec2} {
        var maxProjection: Float = Math.NEGATIVE_INFINITY;
        var index: Int = -1;
        
        // * Finding the index of the furthest point along the normal
        for(vert in vertices) {
            var projection = normal.dot(vert);
            if(projection > maxProjection) {
                maxProjection = projection;
                index = vertices.indexOf(vert);
            }
        }
        
        // * Getting the edge that is the most perpendicular
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
        return distance - (radius1 + radius2);
    }

    public static inline function lineIntersection(l1P1: Vec2, l1P2: Vec2, l1Infinite: Bool, l2P1: Vec2, l2P2: Vec2, l2Infinite: Bool): Vec2 {
        // * Calculating standard form of the lines
        var a1 = l1P2.y - l1P1.y,
            b1 = l1P1.x - l1P2.x,
            c1 = a1*l1P1.x + b1*l1P1.y,
            a2 = l2P2.y - l2P1.y,
            b2 = l2P1.x - l2P2.x,
            c2 = a2*l2P1.x + b2*l2P1.y;
        
        // * Using the standard form to find the intersection point
        var denominator = a1*b2 - a2*b1;

        if(denominator == 0) {
            return null;
        }

        var x = (b2*c1 - b1*c2)/denominator,
            y = (a1*c2 - a2*c1)/denominator,
            rx0 = (x - l1P1.x) / (l1P2.x - l1P1.x),
            ry0 = (y - l1P1.y) / (l1P2.y - l1P1.y),
            rx1 = (x - l2P1.x) / (l2P2.x - l2P1.x),
            ry1 = (y - l2P1.y) / (l2P2.y - l2P1.y);
        
        var valid: Bool = ((rx0 >= 0 && rx0 <= 1) || (ry0 >= 0 && ry0 <=1) || l1Infinite) && ((rx1 >= 0 && rx1 <= 1) || (ry1 >= 0 && ry1 <=1)) || l2Infinite;
        return valid ? vec2(x, y) : null;
    }

    public static inline function boundsIntersection(bounds1: Bounds, bounds2: Bounds): Bool {
        return  (bounds1.min.x < bounds2.max.x &&
                 bounds1.max.x > bounds2.min.x &&
                 bounds1.min.y < bounds2.max.y &&
                 bounds1.max.y > bounds2.min.y );
    }

    public static inline function boundsSeperation(bounds1: Bounds, bounds2: Bounds): Vec2 {
        return null;
    }
    
    // & Finds the intersection point between a polygon and a ray
    public static inline function polyRaycast(poly: CollisionPolygon, ray: Raycast): Vec2 {    
        var vertices: Array<Vec2> = poly.worldVertices;
        var closestIntersection: Vec2 = null;
        var rayPos = ray.origin;
        var castPoint = rayPos + ray.castTo;

        if(pointInPolygon(rayPos, vertices)) {
            return rayPos;
        }

        for(i in 0...vertices.length) {
            var vertex1: Vec2 = vertices[i];
            var vertex2: Vec2 = vertices[(i + 1)%vertices.length];

            var intersection = lineIntersection(vertex1, vertex2, false, rayPos, castPoint, ray.infinite);
            if(intersection != null && ( closestIntersection == null || (intersection - rayPos).length() < (closestIntersection - rayPos).length())) {
                
                closestIntersection = intersection;
            }
        }
        return closestIntersection;
    }

    // & Checks for a collision between an AABB and a ray
    public static inline function aabbRaycast(aabb: CollisionAABB, ray: Raycast): Vec2 {
        var rayPos = ray.origin;
        var castPoint = rayPos + ray.castTo;
        var boxBounds = aabb.bounds;

        var intersectionPoint: Vec2 = null;

        // * Checking if the ray origin is inside the AABB
        if(pointInAABB(rayPos, boxBounds.min, boxBounds.max)) {
            intersectionPoint = rayPos;
        }
        else {
            var intersections: Array<Vec2> = [];

            // * Get every vertex of the AABB to make lines with them
            var vertices: Array<Vec2> = [
                boxBounds.min,
                vec2(boxBounds.max.x, boxBounds.min.y),
                boxBounds.max,
                vec2(boxBounds.min.x, boxBounds.max.y)
            ];
            
            // * Find all line intersection with the edges of the AABB
            for(i in 0...vertices.length) {
                var vertex = vertices[i];
                var nextVertex = vertices[(i + 1)%vertices.length];

                var intersection = lineIntersection(vertex, nextVertex, false, rayPos, castPoint, ray.infinite);
                if(intersection != null) {
                    intersections.push(intersection);
                }
            }

            // * Find the intersection with the closest distance to the ray origin
            var closestIntersection: Vec2 = null;
            for(intersection in intersections) {
                if(closestIntersection == null || distance(closestIntersection, rayPos) > distance(intersection, rayPos)) {
                    closestIntersection = intersection;
                }
            }

            intersectionPoint = closestIntersection;
        }
        return intersectionPoint;
    }

    // & Finds the intersection point between a circle and a ray
    public static inline function circleRaycast(circle: CollisionCircle, ray: Raycast): Vec2 {
        // * Feilds
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
        
        var intersectionPoint: Vec2 = null;
        var realSolution: Bool = true;
        
        if(a <= 0.0000001 || det < 0) {
            // * There are no real solutions
            realSolution = false;
        }
        else if(det == 0) {
            // * There is one solution
            var t = -b/(2*a);
            intersectionPoint = vec2(rayPos.x + t*dx, rayPos.y + t*dy);
        }
        else {
            // * There are two solutions, we will return the solution closest to the
            // * origin point of the ray
            var t = (-b + Math.sqrt(det))/(2*a);
            var intersection1 = vec2(rayPos.x + t*dx, rayPos.y + t*dy);

            t = (-b - Math.sqrt(det))/(2*a);
            var intersection2 = vec2(rayPos.x + t*dx, rayPos.y + t*dy);
            intersectionPoint = distance(intersection1, rayPos) < distance(intersection2, rayPos)
                                ? intersection1 : intersection2;
        }

        if(realSolution) {
            // * Checking if the intersection point is within the line
            var rx = (intersectionPoint.x - rayPos.x) / (castPoint.x - rayPos.x),
                ry = (intersectionPoint.y - rayPos.y) / (castPoint.y - rayPos.y);

            if((rx >= 0 && rx <= 1) || (ry >= 0 && ry <=1) || ray.infinite) {
                return intersectionPoint;
            }
            else {
                return null;
            }
        }
        else {
            return null;
        }
    }

    // & Checks if a coordinite is inside a circle
    public static inline function pointInCircle(point: Vec2, circlePos: Vec2, radius: Float): Bool {
        return point.distance(circlePos) <= radius;
    }

    // & Checks if a coordinite is inside an AABB
    public static inline function pointInAABB(point: Vec2, topLeft: Vec2, bottomRight: Vec2): Bool {
        return  point.x <= bottomRight.x    &&
                point.x >= topLeft.x        &&
                point.y <= bottomRight.y    &&
                point.y >= topLeft.y;
    }

    // & Checks if a coordinite is inside a triangle
    public static inline function pointInTriangle(a: Vec2, b: Vec2, c: Vec2, point: Vec2): Bool {
        var w1: Float = a.x*(c.y - a.y) + (point.y - a.y)*(c.x - a.x) - point.x*(c.y - a.y);
        w1 /= (b.y - a.y)*(c.x - a.x) - (b.x - a.x)*(c.y - a.y);

        var w2: Float = point.y - a.y - w1*(b.y - a.y);
        w2 /= c.y - a.y;

        return  w1 >= 0 && 
                w2 >= 0 && 
                (w1 + w2) <= 1;
    }

    // & Checks if a coordinite is inside a polygon
    public static inline function pointInPolygon(point: Vec2, vertices: Array<Vec2>): Bool {
        var point2 = point + vec2(10000, 0);
        var result: Bool = false;
        
        if(vertices.length > 1) {
            var intersectionCount: Int = 0;
            for(i in 0...vertices.length) {
                var p1: Vec2 = vertices[i],
                    p2: Vec2 = vertices[(i + 1)%vertices.length];
                
                if(lineIntersection(p1, p2, false, point, point2, false) != null) {
                    intersectionCount++;
                }
            }
            result = intersectionCount%2 == 1;
        }

        return result;
    }
}