package hcb;

import h2d.Graphics;
import hxd.snd.Manager;
import hcb.comp.col.*;
import VectorMath;
import hcb.comp.*;

enum PauseMode {
    idle;
    resume;
}

// ^ Project acts as the manager for everything
class Project {
    public var paused: Bool = false;

    public var entities: Array<Entity> = [];

    public var scene: h2d.Scene = null;

    public var collisionWorld: CollisionWorld;
    public var navigationGrids: Map<String, hcb.pathfinding.PathfindingGrid> = [];

    public var ldtkEntityPrefabs: Map<String, ldtk.Entity->Array<Component>> = [];

    public var audioManager: Manager;

    public var calledFrom: Dynamic;

    public function new(calledFrom: Dynamic, collisionCellSize: Float = 256) {
        resetScene();
        audioManager = Manager.get();
        
        this.calledFrom = calledFrom;
        collisionWorld = new CollisionWorld(collisionCellSize);
    }

    public function addEntity(components: Array<hcb.comp.Component>): Entity {
        var entity = new Entity(this);
        entity.addComponents(components);
        entities.push(entity);
        return entity;
    }

    public function update(delta: Float) {
        var targetDelta: Float = 1/60;
        var deltaMult = Math.min(delta/targetDelta, 3);
        for(entity in entities) {
            entity.update(deltaMult);
        }
    }

    public function resetScene() {
        if(scene != null) {
            scene.dispose();
        }
        
        scene = new h2d.Scene();

        for(entity in entities) {
            entity.destroy();
        }

        navigationGrids = [];
        ldtkEntityPrefabs = [];
    }
    
    public function ldtkAddEntities(entities: Array<ldtk.Entity>, ?offset: Vec2): Array<Entity> {
        var entitiesAdded: Array<Entity> = [];
        for(entity in entities) {
            if(ldtkEntityPrefabs.exists(entity.identifier)) {
                var ent = addEntity(ldtkEntityPrefabs[entity.identifier](entity));
                var transform: Transform2D = cast ent.getComponentOfType(Transform2D);
                if(transform != null) {
                    transform.moveTo(vec2(entity.pixelX, entity.pixelY));
                    if(offset != null) {
                        transform.move(offset);
                    }
                }
                entitiesAdded.push(ent);
            }
        }

        return entitiesAdded;
    }

    public function ldtkAddCollisionLayer(layer: ldtk.Layer_Tiles, ?tags: Array<String>, ?offset: Vec2, ?customShapes: Map<Int, Vec2->Int->CollisionShape>) {
        var tileSize = layer.gridSize;
        for(i in 0...layer.cWid) {
            for(j in 0...layer.cHei) {
                var hasTile = layer.hasAnyTileAt(i, j);
                if(hasTile) {
                    var colTile = layer.getTileStackAt(i, j);
                    var org = new Vec2(i*tileSize, j*tileSize);

                    var newShape: CollisionShape;
                    if(customShapes != null && customShapes.exists(colTile[0].tileId)) {
                        newShape = customShapes[colTile[0].tileId](org, tileSize);
                    }
                    else {
                        var staticColShape = new CollisionAABB("Static", tileSize, tileSize);
                        staticColShape.offsetX = org.x;
                        staticColShape.offsetY = org.y;
                        newShape = staticColShape;
                    }
                    if(offset != null) {
                        newShape.offsetX += offset.x;
                        newShape.offsetY += offset.y;
                    }

                    if(tags != null) {
                        for(tag in tags) {
                            newShape.tags.push(tag);
                        }
                    }
                    collisionWorld.addShape(newShape);
                }
            }
        }
    }
}