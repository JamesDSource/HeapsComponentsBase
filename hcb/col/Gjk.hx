package hcb.col;

import hcb.comp.col.*;
import VectorMath;

using hcb.math.Vector;

class Gjk {
    // & Checks two shapes with the GJK algorithm
    public static function gjk2d(shape1: CollisionShape, shape2: CollisionShape): Bool {
        // * Get initial support point in any direction
        var support: Vec2 = getSupport(shape1, shape2, vec2(1, 0));
        
        // * Create a simplex in 2 dimensions (max 3 vertices)
        var simplex: Simplex<Vec2> = new Simplex<Vec2>(2);
        simplex.push(support);

        var direction: Vec2 = -support;
        while(true) {
            support = getSupport(shape1, shape2, direction);

            if(!sameDirection(direction, support))
                return false;

            simplex.push(support);

            if(nextSimplex(simplex, direction))
                return true;
        }
        return false;
    }

    private static inline function getSupport(a: CollisionShape, b: CollisionShape, d: Vec2): Vec2 {
        return a.getSupportPoint(d) - b.getSupportPoint(-d);
    }

    private overload static inline extern function nextSimplex(simplex: Simplex<Vec2>, d: Vec2): Bool {
        switch(simplex.size) {
            case 2:
                return gjkLine(simplex, d);
            case 3:
                return gjkTriangle(simplex, d);
            default:
                return false;
        }
    }

    private overload static inline extern function nextSimplex(simplex: Simplex<Vec3>, d: Vec3): Bool {
        switch(simplex.size) {
            case 2:
                return gjkLine(simplex, d);
            case 3:
                return gjkTriangle(simplex, d);
            case 4:
                return gjkTetrahedron(simplex, d);
            default:
                return false;
        }
    }

    // * 2D line case
    private overload static inline extern function gjkLine(simplex: Simplex<Vec2>, d: Vec2): Bool {
        var a = simplex.get(0);
        var b = simplex.get(1);
        
        var ab = b - a;
        var ao = -a;
        
        if(sameDirection(ab, ao)) {
            var dLeft = ab.crossLeft();
            var dRight = ab.crossRight();
            if(dLeft.dot(ao) > dRight.dot(ao))
                d.set(dLeft);
            else
                d.set(dRight);
            //d.set(ab.tripleProduct(ao, ab).normalize());
        }
        else
            d.set(ao.normalize());

        return false;
    }

    private overload static inline extern function gjkLine(simplex: Simplex<Vec3>, d: Vec3): Bool {
        var a = simplex.get(0);
        var b = simplex.get(1);
        
        var ab = b - a;
        var ao = -a;
        
        if(sameDirection(ab, ao))
            d.set(ab.tripleProduct(ao, ab).normalize());
        else
            d.set(ao.normalize());

        return false;
    }

    private overload static inline extern function gjkTriangle(simplex: Simplex<Vec2>, d: Vec2): Bool {
        var a = simplex.get(0);
        var b = simplex.get(1);
        var c = simplex.get(2);

        var ao = -a;
        var ab = b - a;
        var ac = c - a;

        var abPerp = ac.tripleProduct(ab, ab);
        var acPerp = ab.tripleProduct(ac, ac);

        var result: Bool = false;
        if(sameDirection(abPerp, ao)) {
            simplex.remove(c);
            d.set(abPerp);
        }
        else {
            if(sameDirection(acPerp, ao)) {
                simplex.remove(b);
                d.set(acPerp);
            }
            else
                result = true;
        }
        
        return result;
    }

    private overload static inline extern function gjkTriangle(simplex: Simplex<Vec3>, d: Vec3): Bool {
        return false;
    }

    private static inline function gjkTetrahedron(simplex: Simplex<Vec3>, d: Vec3): Bool {
        return false;
    }

    private overload static inline extern function sameDirection(dir: Vec2, ao: Vec2): Bool {
        return dir.dot(ao) > 0;
    }

    private overload static inline extern function sameDirection(dir: Vec3, ao: Vec3): Bool {
        return dir.dot(ao) > 0;
    }
}