package hcb.comp.col;

import hcb.comp.col.CollisionShape.Bounds;
import VectorMath;

class Collisions {
    public static function test(shape1: CollisionShape, shape2: CollisionShape): Bool {
        if(!shape1.canInteractWith(shape2)) {
            return false;
        }
        
        // * Poly with poly
        if(Std.isOfType(shape1, CollisionPolygon) && Std.isOfType(shape2, CollisionPolygon)) {
            return polyWithPoly(cast(shape1, CollisionPolygon), cast(shape2, CollisionPolygon));
        }
        // * Ray with ray
        else if(Std.isOfType(shape1, CollisionRay) && Std.isOfType(shape2, CollisionRay)) {
            return rayWithRay(cast(shape1, CollisionRay), cast(shape2, CollisionRay)) != null;
        }
        // * Circle with circle
        else if(Std.isOfType(shape1, CollisionCircle) && Std.isOfType(shape2, CollisionCircle)) {
            return circleWithCircle(cast(shape1, CollisionCircle), cast(shape2, CollisionCircle));
        }
        // * AABB with AABB
        else if(Std.isOfType(shape1, CollisionAABB) && Std.isOfType(shape2, CollisionAABB)) {
            // ^ We already tested for a bounds intersection, so if the code made it this far,
            // ^ aabbWithAabb is already true
            return true;
        }
        // * Circle with ray
        else if(Std.isOfType(shape1, CollisionCircle) && Std.isOfType(shape2, CollisionRay)) {
            return circleWithRay(cast(shape1, CollisionCircle), cast(shape2, CollisionRay)) != null;
        }
        // * Ray with circle
        else if(Std.isOfType(shape1, CollisionRay) && Std.isOfType(shape2, CollisionCircle)) {
            return circleWithRay(cast(shape2, CollisionCircle), cast(shape1, CollisionRay)) != null;
        }
        // * Poly with ray
        else if(Std.isOfType(shape1, CollisionPolygon) && Std.isOfType(shape2, CollisionRay)) {
            return polyWithRay(cast(shape1, CollisionPolygon), cast(shape2, CollisionRay)) != null;
        }
        // * Ray with poly
        else if(Std.isOfType(shape1, CollisionRay) && Std.isOfType(shape2, CollisionPolygon)) {
            return polyWithRay(cast(shape2, CollisionPolygon), cast(shape1, CollisionRay)) != null;
        }
        // * AABB with ray
        else if(Std.isOfType(shape1, CollisionAABB) && Std.isOfType(shape2, CollisionRay)) {
            return aabbwithRay(cast(shape1, CollisionAABB), cast(shape2, CollisionRay)) != null;
        }
        // * Ray with AABB
        else if(Std.isOfType(shape1, CollisionRay) && Std.isOfType(shape2, CollisionAABB)) {
            return aabbwithRay(cast(shape2, CollisionAABB), cast(shape1, CollisionRay)) != null;
        }
        // * AABB with poly
        else if(Std.isOfType(shape1, CollisionAABB) && Std.isOfType(shape2, CollisionPolygon)) {
            return aabbWithPoly(cast(shape1, CollisionAABB), cast(shape2, CollisionPolygon));
        }
        // * Poly with AABB
        else if(Std.isOfType(shape1, CollisionPolygon) && Std.isOfType(shape2, CollisionAABB)) {
            return aabbWithPoly(cast(shape2, CollisionAABB), cast(shape1, CollisionPolygon));
        }
        // * Poly with circle
        else if(Std.isOfType(shape1, CollisionPolygon) && Std.isOfType(shape2, CollisionCircle)) {
            return polyWithCircle(cast(shape1, CollisionPolygon), cast(shape2, CollisionCircle));
        }
        // * Circle with poly
        else if(Std.isOfType(shape1, CollisionCircle) && Std.isOfType(shape2, CollisionPolygon)) {
            return polyWithCircle(cast(shape2, CollisionPolygon), cast(shape1, CollisionCircle));
        }
        // * AABB with Circle
        else if(Std.isOfType(shape1, CollisionAABB) && Std.isOfType(shape2, CollisionCircle)) {
            return aabbWithCircle(cast(shape1, CollisionAABB), cast(shape2, CollisionCircle));
        }
        // * Circle with AABB
        else if(Std.isOfType(shape1, CollisionCircle) && Std.isOfType(shape2, CollisionAABB)) {
            return aabbWithCircle(cast(shape2, CollisionAABB), cast(shape1, CollisionCircle));
        }
        else {
            trace("Unknown collision combination");
            return false;
        }
    }

    // & Tests for an intersection with a ray, and returns the point of collision
    public static function rayTestIntersection(ray: CollisionRay, shape: CollisionShape): Vec2 {
        if(!ray.canInteractWith(shape)) {
            return null;
        }

        if(Std.isOfType(shape, CollisionPolygon)) {
            return polyWithRay(cast(shape, CollisionPolygon), ray);
        }
        else if(Std.isOfType(shape, CollisionRay)) {
            return rayWithRay(ray, cast(shape, CollisionRay));
        }
        else if(Std.isOfType(shape, CollisionCircle)) {
            return circleWithRay(cast(shape, CollisionCircle), ray);
        }
        else if(Std.isOfType(shape, CollisionAABB)) {
            return aabbwithRay(cast(shape, CollisionAABB), ray);
        }
        else {
            return null;
        }
    }


    // & Checks for a collision between two polygons
    public static inline function polyWithPoly(polygon1: CollisionPolygon, polygon2: CollisionPolygon): Bool {
        var poly1: CollisionPolygon;
        var poly2: CollisionPolygon;

        var isCollision: Bool = true;

        // * Runs the code twice, switching which role each polygon plays both times
        for(i in 0...2) {
            if(i == 0) {
                poly1 = polygon1;
                poly2 = polygon2;
            }
            else {
                poly1 = polygon2;
                poly2 = polygon1;
            }

            var poly1V = poly1.getGlobalTransformedVertices();
            var poly2V = poly2.getGlobalTransformedVertices();
            for(j in 0...poly1V.length) {
                var vert: Vec2 = poly1V[j];
                var nextVert: Vec2 = poly1V[(j + 1)%poly1V.length];
                var axisProj: Vec2 = new Vec2(-(vert.y - nextVert.y), vert.x - nextVert.x);

                // * Projecting each point from both polygons onto
                // * the axis, and seeing if they match up
                var minR1 = Math.POSITIVE_INFINITY;
                var maxR1 = Math.NEGATIVE_INFINITY;
                for(vertex in poly1V) {
                    var dot: Float = dot(vertex, axisProj);
                    minR1 = Math.min(minR1, dot);
                    maxR1 = Math.max(maxR1, dot);
                } 

                var minR2 = Math.POSITIVE_INFINITY;
                var maxR2 = Math.POSITIVE_INFINITY;
                for(vertex in poly2V) {
                    var dot: Float = dot(vertex, axisProj);
                    minR2 = Math.min(minR2, dot);
                    maxR2 = Math.max(maxR2, dot);
                }
                
                // * Checking if the shapes overlap
                if(!(maxR2 >= minR1 && maxR1 >= minR2)) {
                    isCollision = false;
                    break;
                }
            }

        }
        return isCollision;
    }

    // & Checks for a collision between two circles
    public static inline function circleWithCircle(circle1: CollisionCircle, circle2: CollisionCircle) {
        var absPos1 = circle1.getAbsPosition(),
            absPos2 = circle2.getAbsPosition();

        return radiusIntersection(absPos1, absPos2, circle1.radius, circle2.radius);
    }

    // & Checks for a collision between a polygon and a circle
    public static inline function polyWithCircle(poly: CollisionPolygon, circle: CollisionCircle): Bool {
        var polyV = poly.getGlobalTransformedVertices();
        var circleCenter = circle.getAbsPosition();
        var circleRadius = circle.radius;
        var closestVertex: Vec2 = null;
        var isCollision: Bool = true;

        // * Checking if the center point in inside the polygon
        if(!pointInPolygon(polyV, circleCenter)){
            // * First iteration checks the polygon
            for(i in 0...polyV.length) {
                var vert = polyV[i];
                var nextVert = polyV[(i + 1)%polyV.length];
                var axisProj: Vec2 = vec2(-(vert.y - nextVert.y), vert.x - nextVert.x);
                
                // * Getting the vetex closest to the center of the circle
                if(closestVertex == null || distance(closestVertex, circleCenter) > distance(vert, circleCenter)) {
                    closestVertex = vert;
                }

                // * Projecting each point from the polygon
                var minR1 = Math.POSITIVE_INFINITY;
                var maxR1 = Math.NEGATIVE_INFINITY;
                for(vertex in polyV) {
                    var dot: Float = dot(vertex, axisProj);
                    minR1 = Math.min(minR1, dot);
                    maxR1 = Math.max(maxR1, dot);
                } 
                // * Projecting the center of the circle and adding/subtracting the radius
                var projNormal = normalize(axisProj);
                var minR2 = (circleCenter - projNormal*circleRadius).dot(axisProj);
                var maxR2 = (circleCenter + projNormal*circleRadius).dot(axisProj);
                
                // * Checking if the shapes overlap
                if(!(maxR2 >= minR1 && maxR1 >= minR2)) {
                    isCollision = false;
                    break;
                }
            }

            // * Checking the axis between the closest vertex and the circle center
            if(closestVertex == null) {
                isCollision = false;
            }
            else if(isCollision) { 
                var axisProj: Vec2 = vec2(-(closestVertex.y - circleCenter.y), closestVertex.x - circleCenter.x);
                
                // * Projecting each point from the polygon
                var minR1 = Math.POSITIVE_INFINITY;
                var maxR1 = Math.NEGATIVE_INFINITY;
                for(vertex in polyV) {
                    var dot: Float = dot(vertex, axisProj);
                    minR1 = Math.min(minR1, dot);
                    maxR1 = Math.max(maxR1, dot);
                } 
                // * Projecting the center of the circle and adding/subtracting the radius
                var projNormal = normalize(axisProj);
                var minR2 = (circleCenter - projNormal*circleRadius).dot(axisProj);
                var maxR2 = (circleCenter + projNormal*circleRadius).dot(axisProj);
                
                // * Checking if the shapes overlap
                if(!(maxR2 >= minR1 && maxR1 >= minR2)) {
                    isCollision = false;
                }
            }
        }
        return isCollision;
    }

    // & Finds the intersection point between two rays
    public static inline function rayWithRay(ray1: CollisionRay, ray2: CollisionRay): Vec2 {
        return lineIntersection(
            ray1.getAbsPosition(), 
            ray1.getGlobalTransformedCastPoint(), 
            ray1.infinite,
            ray2.getAbsPosition(),
            ray2.getGlobalTransformedCastPoint(),
            ray2.infinite
        );
    }
    
    // & Finds the intersection point between a polygon and a ray
    public static inline function polyWithRay(poly: CollisionPolygon, ray: CollisionRay): Vec2 {    
        var vertices: Array<Vec2> = poly.getGlobalTransformedVertices();
        var closestIntersection: Vec2 = null;
        var rayPos = ray.getAbsPosition();

        if(pointInPolygon(vertices, rayPos)) {
            return rayPos;
        }

        for(i in 0...vertices.length) {
            var vertex1: Vec2 = vertices[i];
            var vertex2: Vec2 = vertices[(i + 1)%vertices.length];

            var intersection = lineIntersection(vertex1, vertex2, false, rayPos, ray.getGlobalTransformedCastPoint(), ray.infinite);
            if(intersection != null && ( closestIntersection == null || (intersection - rayPos).length() < (closestIntersection - rayPos).length())) {
                
                closestIntersection = intersection;
            }
        }
        return closestIntersection;
    }

    // & Finds the intersection point between a circle and a ray
    public static inline function circleWithRay(circle: CollisionCircle, ray: CollisionRay): Vec2 {
        // * Feilds
        var circlePos = circle.getAbsPosition(),
            radius = circle.radius,
            rayPos = ray.getAbsPosition(),
            castPoint = ray.getGlobalTransformedCastPoint(),
            
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

    // & Checks for a collision between an AABB and a ray
    public static inline function aabbwithRay(aabb: CollisionAABB, ray: CollisionRay): Vec2 {
        var rayPos = ray.getAbsPosition();
        var boxBounds = aabb.bounds;

        var intersectionPoint: Vec2 = null;

        // * Checking if the ray origin is inside the AABB
        if(pointInAABB(rayPos, boxBounds.min, boxBounds.max)) {
            intersectionPoint = rayPos;
        }
        else {
            var intersections: Array<Vec2> = [];
            var castPoint = ray.getGlobalTransformedCastPoint();

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

    // & Checks for a collision between an AABB and a polygon
    public static inline function aabbWithPoly(aabb: CollisionAABB, poly: CollisionPolygon): Bool {
        var isCollision: Bool = true;

        // * Runs the code twice, switching between checking the poly to the AABB
        var boxBounds = aabb.bounds;
        for(i in 0...2) {
            var poly1V: Array<Vec2> = [];
            var poly2V: Array<Vec2> = [];
            if(i == 0) {
                poly1V = poly.getGlobalTransformedVertices();
                poly2V = [
                    boxBounds.min,
                    vec2(boxBounds.max.x, boxBounds.min.y),
                    boxBounds.max,
                    vec2(boxBounds.min.x, boxBounds.max.y)
                ];
            }
            else {
                poly2V = [
                    boxBounds.min,
                    vec2(boxBounds.max.x, boxBounds.min.y),
                    boxBounds.max,
                    vec2(boxBounds.min.x, boxBounds.max.y)
                ];
                poly2V = poly.getGlobalTransformedVertices();
            }

            
            for(j in 0...poly1V.length) {
                var vert: Vec2 = poly1V[j];
                var nextVert: Vec2 = poly1V[(j + 1)%poly1V.length];
                var axisProj: Vec2 = vec2(-(vert.y - nextVert.y), vert.x - nextVert.x);

                // * Projecting each point from both polygons onto
                // * the axis, and seeing if they match up
                var minR1 = Math.POSITIVE_INFINITY;
                var maxR1 = Math.NEGATIVE_INFINITY;
                for(vertex in poly1V) {
                    var dot: Float = dot(vertex, axisProj);
                    minR1 = Math.min(minR1, dot);
                    maxR1 = Math.max(maxR1, dot);
                } 

                var minR2 = Math.POSITIVE_INFINITY;
                var maxR2 = Math.POSITIVE_INFINITY;
                for(vertex in poly2V) {
                    var dot: Float = dot(vertex, axisProj);
                    minR2 = Math.min(minR2, dot);
                    maxR2 = Math.max(maxR2, dot);
                }
                
                // * Checking if the shapes overlap
                if(!(maxR2 >= minR1 && maxR1 >= minR2)) {
                    isCollision = false;
                    break;
                }
            }

            if(!isCollision) {
                break;
            }
        }
        return isCollision;
    }

    // & Checks for a collision between an AABB and a circle
    public static inline function aabbWithCircle(aabb: CollisionAABB, circle: CollisionCircle): Bool {
        var bounds = aabb.bounds;
        var aabbMidPoint = bounds.min + vec2((aabb.transformedWidth - 1)/2, (aabb.transformedHeight - 1)/2);

        var circlePos = circle.getAbsPosition();

        var differenceVector = circlePos.clone();
        differenceVector.x = hxd.Math.clamp(differenceVector.x, bounds.min.x, bounds.max.x);
        differenceVector.y = hxd.Math.clamp(differenceVector.y, bounds.min.y, bounds.max.y);

        return distance(differenceVector, circlePos) < circle.radius;
    }

    // & Checks if two radiuses intersect
    public static inline function radiusIntersection(pos1: Vec2, pos2: Vec2, radius1: Float, radius2: Float): Bool {
        var distance = (pos1 - pos2).length();
        return distance < radius1 + radius2;
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
    public static inline function pointInPolygon(vertices: Array<Vec2>, point: Vec2): Bool {
        var isPoint: Bool = false;

        if(vertices.length >= 3) {
            var p1: Vec2 = vertices[0];

            for(i in 2...vertices.length) {
                var p2: Vec2 = vertices[i - 1],
                    p3: Vec2 = vertices[i];
                
                if(pointInTriangle(p1, p2, p3, point)) {
                    isPoint = true;
                    break;
                }
            }
        }
        return isPoint;
    }
}