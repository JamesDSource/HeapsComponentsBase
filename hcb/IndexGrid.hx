package hcb;

import hcb.comp.col.*;
import VectorMath;

typedef IGrid = { 
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
    public static function ldtkTilesConvert(tileLayer: ldtk.Layer_Tiles): IGrid {
        var indexs: Array<Int> = [];

        for(i in 0...tileLayer.cHei) {
            for(j in 0...tileLayer.cWid) {
                var hasTile = tileLayer.hasAnyTileAt(j, i);
                if(hasTile) {
                    indexs.push(tileLayer.getTileStackAt(j, i)[0].tileId);
                }
                else {
                    indexs.push(-1);
                }
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
    public static function convertToCollisionShapes(indexGrid: IGrid, ?offset: Vec2, ?tags: Array<String>, ?customShapes: Map<Int, Vec2->Float->CollisionShape>): Array<CollisionShape> {
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
                var staticColShape = new CollisionAABB("Static", cellSize, cellSize);
                staticColShape.offsetX = org.x;
                staticColShape.offsetY = org.y;
                newShape = staticColShape;
            }

            if(newShape != null) {
                // * Adding a position offset if the indexGrid has one
                if(indexGrid.position != null) {
                    newShape.offsetX += indexGrid.position.x;
                    newShape.offsetY += indexGrid.position.y;
                }

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

    public static inline function slopeBuild(slopeFace: SlopeFace, origin: Vec2, tileSize: Float): CollisionShape {
        var verts: Array<Vec2> = [];

        switch(slopeFace) {
            case SlopeFace.TopLeft:
                verts = [
                    vec2(0, tileSize),
                    vec2(tileSize, 0),
                    vec2(tileSize, tileSize)
                ];
            case SlopeFace.TopRight:
                verts = [
                    vec2(0, 0),
                    vec2(0, tileSize ),
                    vec2(tileSize, tileSize)
                ];
            case SlopeFace.BottomLeft:
                verts = [
                    vec2(0, 0),
                    vec2(tileSize, tileSize),
                    vec2(tileSize, 0)
                ];
            case SlopeFace.BottomRight:
                verts = [
                    vec2(0, 0),
                    vec2(0, tileSize),
                    vec2(tileSize, 0)
                ];
        }
        var shape: CollisionPolygon = new CollisionPolygon("poly", verts);
        shape.offsetX = origin.x;
        shape.offsetY = origin.y;
        return shape;
    }
}