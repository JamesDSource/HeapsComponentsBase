package hcb;

import hcb.comp.col.*;
import VectorMath;

typedef IndexGridData = { 
    indexs: Array<Int>,
    width: Int,
    height: Int,
    ?cellSize: Null<Float>,
    ?position: Vec2
}

enum SlopeFace {
    TopLeft;
    TopRight;
    BottomLeft;
    BottomRight;
}

class IndexGrid {
    #if ldtk_haxe_api
    public static function ldtkTilesConvert(tileLayer: ldtk.Layer_Tiles): IndexGridData {
        var indexs: Array<Int> = [];

        for(i in 0...tileLayer.cHei) {
            for(j in 0...tileLayer.cWid) {
                var hasTile = tileLayer.hasAnyTileAt(j, i);
                if(hasTile)
                    indexs.push(tileLayer.getTileStackAt(j, i)[0].tileId);
                else
                    indexs.push(-1);
            }
        }

        return {
            indexs: indexs,
            width: tileLayer.cWid,
            height: tileLayer.cHei,
            cellSize: tileLayer.gridSize
        };
    }
    #end

    // & Returns an array of Collision shapes. By default, these will be AABBs with their offsets set to their
    // & position on the grid. This can be overriden with the custom shapes map that stores functions with indexs 
    // & that take in grid position, the cell size, and outputs a collision shape to use.
    public static function convertToCollisionShapes(indexGrid: IndexGridData, ?offset: Vec2, ?tags: Array<String>, ?customShapes: Map<Int, Vec2->Float->CollisionShape>): Array<CollisionShape> {
        var shapes: Array<CollisionShape> = [];
        for(i in 0...indexGrid.indexs.length) {
            // * Getting the coordinates
            var y: Int = hxd.Math.floor(i / indexGrid.width);
            var x: Int = i - y*indexGrid.width;

            // * Getting the origin point
            var org: Vec2 = vec2(x, y);
            var cellSize = indexGrid.cellSize == null ? 1 : indexGrid.cellSize;
            org *= cellSize;
            if(offset != null)
                org += offset;

            // * Getting the collision shape
            var index: Int = indexGrid.indexs[i];
            var newShape: CollisionShape = null;
            if(customShapes != null && customShapes.exists(index)) {
                newShape = customShapes[index](org, cellSize);
            }
            else if(index != -1) {
                var staticColShape = new CollisionAABB(cellSize, cellSize);
                staticColShape.transform.setPosition(indexGrid.position != null ? indexGrid.position + org : org);
                newShape = staticColShape;
            }

            if(newShape != null) {
                // * Adding tags if defined
                if(tags != null) {
                    for(tag in tags) {
                        newShape.tags.push(tag);
                    }
                }

                shapes.push(newShape);
            }
        }
        return shapes;
    }

    public static inline function slopeBuild(slopeFace: SlopeFace, widthPercent: Float = 1.0, heightPercent: Float = 1.0, origin: Vec2, tileSize: Float): CollisionShape {
        var supportingPoint: Vec2;
        var hDir: Int = 0, vDir: Int = 0;
        switch(slopeFace) {
            case SlopeFace.TopLeft:
                supportingPoint = vec2(tileSize, tileSize);
                hDir = vDir = -1;
            case SlopeFace.TopRight:
                supportingPoint = vec2(0, tileSize);
                hDir = 1;
                vDir = -1;
            case SlopeFace.BottomLeft:
                supportingPoint = vec2(tileSize, 0);
                hDir = -1;
                vDir = 1;
            case SlopeFace.BottomRight:
                supportingPoint = vec2(0, 0);
                hDir = vDir = 1;
        }
        
        var verts: Array<Vec2> = [
            supportingPoint,
            vec2(supportingPoint.x + hDir*widthPercent*tileSize, supportingPoint.y),
            vec2(supportingPoint.x, supportingPoint.y + vDir*heightPercent*tileSize)
        ];
        
        var shape: CollisionPolygon = new CollisionPolygon(verts);
        shape.transform.setPosition(origin);
        return shape;
    }

    public static inline function bboxBuild(widthPercent: Float, heightPercent: Float, offsetPercent: Vec2, origin: Vec2, tileSize: Float): CollisionShape {
        var shape: CollisionAABB = new CollisionAABB(widthPercent*tileSize, heightPercent*tileSize);
        shape.transform.setPosition(origin + offsetPercent*tileSize);
        return shape;
    }
}