package hcb.col;

import hcb.comp.Body;
import hcb.physics.PhysicsWorld;
import hcb.comp.col.*;
import VectorMath;

using hcb.math.Vector;

enum SlopeFace {
    TopLeft;
    TopRight;
    BottomLeft;
    BottomRight;
}

class CollisionGrid {
    public var indexGrid: IndexGrid;
    public var cellWidth: Float;
    public var cellHeight: Float;
 
    private var shapes: Array<CollisionShape> = [];
    public var customShapes: Map<Int, (Float, Float)->CollisionShape> = [];
    public var physicsOptions: BodyOptions = null;

    public var collisionWorld(default, set): CollisionWorld = null;
    public var physicsWorld(default, set): PhysicsWorld = null;

    // Removes all shapes from the previous collisionWorld and adds to the new one
    private function set_collisionWorld(collisionWorld: CollisionWorld): CollisionWorld {
        if(this.collisionWorld != null)
            for(shape in shapes)
                this.collisionWorld.removeShape(shape);

        if(collisionWorld != null)
            for(shape in shapes)
                collisionWorld.addShape(shape);

        return this.collisionWorld = collisionWorld;
    }

    // Removes all boides from the previous physicsWorld and adds to the new one
    private function set_physicsWorld(physicsWorld: PhysicsWorld): PhysicsWorld {
        if(this.physicsWorld != null)
            for(shape in shapes)
                this.physicsWorld.removeBody(shape.body);

        if(physicsWorld != null)
            for(shape in shapes)
                if(shape.body != null)
                    physicsWorld.addBody(shape.body);

        return this.physicsWorld = physicsWorld;
    }

    public function new(indexGrid: IndexGrid, ?collisionWorld: CollisionWorld, ?cellWidth: Null<Float>, ?cellHeight: Null<Float>) {
        this.indexGrid = indexGrid;
        
        this.collisionWorld = collisionWorld;

        if(cellWidth != null) {
            this.cellWidth = cellWidth;
            this.cellHeight = cellHeight != null ? cellHeight : cellWidth;
        }
        else if(indexGrid.cellSize != null)
            this.cellHeight = this.cellWidth = indexGrid.cellSize;
        else
            this.cellHeight = this.cellWidth = 1;
    }

    // Rebuilds the entire collision grid
    public function createShapes(destroyPrevious: Bool = true) {
        if(destroyPrevious)
            for(shape in shapes)
                removeCollider(shape);

        var grid: Array<CollisionShape> = [];
        var epSqr: Float = hxd.Math.EPSILON*hxd.Math.EPSILON;

        // Create the initial shapes
        for(i in 0...indexGrid.length) {
            var index = indexGrid[i];
            if(index == -1) {
                grid.push(null);
                continue;
            }

            var coords = indexGrid.getCoords(i);
            var x: Int = Std.int(coords.x);
            var y: Int = Std.int(coords.y);
            var collider = createCollider(index, x, y);
            grid.push(collider);
        }

        var edges: Array<CollisionPolygon> = [];

        // Reduce the polygons into edges
        for(i in 0...grid.length) {
            if(grid[i] == null)
                continue;

            var collider = grid[i];
            if(!Std.isOfType(collider, CollisionPolygon)) {
                addCollider(collider);
                continue;
            }

            var poly = cast(collider, CollisionPolygon);
            var wv = poly.worldVertices;
            var coords = indexGrid.getCoords(i);
            var x: Int = Std.int(coords.x);
            var y: Int = Std.int(coords.y);

            var check = [
                {x: x - 1, y: y},
                {x: x + 1, y: y},
                {x: x, y: y - 1},
                {x: x, y: y + 1}
            ];

            // Find the connnecting edges
            var connecting: Array<Int> = [];
            for(coords in check) { 
                if(coords.x >= 0 && coords.y >= 0 && coords.x < indexGrid.width && coords.y < indexGrid.height) {
                    var index = indexGrid.coordsToIndex(coords.x, coords.y);
                    if(grid == null || !Std.isOfType(grid[index], CollisionPolygon))
                        continue;

                    var poly2 = cast(grid[index], CollisionPolygon);
                    var wv2 = poly2.worldVertices;

                    for(j in 0...wv.length) {
                        if(connecting.contains(j))
                            continue;

                        var vertex: Vec2 = wv[j];
                        var nextVertex: Vec2 = wv[(j + 1)%wv.length];
                        for(k in 0...wv2.length) {
                            var vertex2: Vec2 = wv2[k];
                            var nextVertex2: Vec2 = wv2[(k + 1)%wv2.length];

                            if( (vertex.distanceSquared(vertex2) < epSqr && nextVertex.distanceSquared(nextVertex2) < epSqr) || 
                                (vertex.distanceSquared(nextVertex2) < epSqr && nextVertex.distanceSquared(vertex2) < epSqr)
                            ) connecting.push(j);
                        }
                    }
                }
            }

            // Create edge polygons out of non-connecting edges
            for(j in 0...wv.length) {
                if(connecting.contains(j))
                    continue;

                var vertex: Vec2 = wv[j];
                var nextVertex: Vec2 = wv[(j + 1)%wv.length];
                var edge = new CollisionPolygon([vec2(0, 0), nextVertex - vertex], false);
                edge.transform.setPosition(vertex);

                edges.push(edge);
            }
        }

        // Combine the edges
        for(edge1 in edges.copy()) {
            if(!edges.contains(edge1))
                continue;

            var wv1 = edge1.worldVertices;
            var across1 = normalize(wv1[1] - wv1[0]);
            for(edge2 in edges.copy()) {
                if(edge1 == edge2)
                    continue;

                var wv2 = edge2.worldVertices;
                var across2 = normalize(wv2[1] - wv2[0]);
                if(across1.distanceSquared(across2) > epSqr)
                    continue;
                
                var found: Bool = false;
                for(i in 0...wv1.length) {
                    for(j in 0...wv2.length) {
                        if(wv1[i].distanceSquared(wv2[j]) < epSqr) {
                            edges.remove(edge2);

                            var v1 = i == 0 ? wv1[1] : wv1[0];
                            var v2 = j == 0 ? wv2[1] : wv2[0];
                            var newEdges =  v1.dot(across1) < v2.dot(across2)
                                            ? [v1, v2] : [v2, v1];
                            edge1.setVertices([vec2(0, 0), newEdges[1] - newEdges[0]], false);
                            edge1.transform.setPosition(newEdges[0]);
                            wv1 = edge1.worldVertices;
                            found = true;
                            break;
                        }
                        if(found)
                            break;
                    }
                }
            }
        }

        // Add the edges
        for(edge in edges)
            addCollider(edge);
    }

    private function removeCollider(shape: CollisionShape) {
        if(collisionWorld != null)
            collisionWorld.removeShape(shape);
        
        if(physicsWorld != null)
            physicsWorld.removeBody(shape.body);
    }

    private function addCollider(shape: CollisionShape) {
        if(physicsOptions != null) {
            new Body(physicsOptions).shape = shape;
            if(physicsWorld != null)
                physicsWorld.addBody(shape.body);
        }

        if(collisionWorld != null)
            collisionWorld.addShape(shape);
    }

    private function createCollider(index: Int, x: Int, y: Int): CollisionShape {
        var collider = customShapes.exists(index) ? customShapes[index](cellWidth, cellHeight) : CollisionPolygon.rectangle(cellWidth, cellHeight);
        collider.transform.translate(vec2(x*cellWidth, y*cellHeight));
        return collider;
    }

    // Used with .bind in the customShapes map to make quick and easy 45 degree slopes
    public static inline function slopeBuild(slopeFace: SlopeFace, widthPercent: Float = 1.0, heightPercent: Float = 1.0, tileW: Float, tileH: Float): CollisionShape {
        var supportingPoint: Vec2;
        var hDir: Int = 0, vDir: Int = 0;
        switch(slopeFace) {
            case SlopeFace.TopLeft:
                supportingPoint = vec2(tileW, tileH);
                hDir = vDir = -1;
            case SlopeFace.TopRight:
                supportingPoint = vec2(0, tileH);
                hDir = 1;
                vDir = -1;
            case SlopeFace.BottomLeft:
                supportingPoint = vec2(tileW, 0);
                hDir = -1;
                vDir = 1;
            case SlopeFace.BottomRight:
                supportingPoint = vec2(0, 0);
                hDir = vDir = 1;
        }
        
        var verts: Array<Vec2> = [
            supportingPoint,
            vec2(supportingPoint.x + hDir*widthPercent*tileW, supportingPoint.y),
            vec2(supportingPoint.x, supportingPoint.y + vDir*heightPercent*tileH)
        ];
        
        var shape: CollisionPolygon = new CollisionPolygon(verts);
        return shape;
    }
}