package hcb;

import hxd.snd.Manager;
import hcb.comp.col.*;
import ldtk.Layer_Entities;
import hcb.math.Vector2;
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
    public var renderables: h2d.Layers;

    public var camera: h2d.Camera;
    public var cameraFollow: h2d.Object = null;

    public var collisionWorld: CollisionWorld = new CollisionWorld();
    public var navigationGrids: Map<String, PathfindingGrid> = [];

    public var ldtkEntityPrefabs: Map<String, Void->Array<Component>> = [];

    public var audioManager: Manager;
    public var listenerFollow: h2d.Object;

    public var calledFrom: Dynamic;

    public function new(calledFrom: Dynamic) {
        resetScene();
        audioManager = Manager.get();
        this.calledFrom = calledFrom;
    }

    public function addEntity(components: Array<hcb.comp.Component>): Entity {
        var entity = new Entity(this);
        for(component in components) {
            entity.addComponent(component, false);
        }
        for(component in components) {
            component.init();
        }
        entities.push(entity);
        return entity;
    }

    public function update(delta: Float) {
        var targetDelta: Float = 1/60;
        var deltaMult = Math.min(delta/targetDelta, 3);
        for(entity in entities) {
            entity.update(deltaMult);
        }
        
        if(cameraFollow != null) {
            camera.x = cameraFollow.x;
            camera.y = cameraFollow.y;
        }
        
        if(listenerFollow != null) {
            audioManager.listener.position.x = listenerFollow.x;
            audioManager.listener.position.y = listenerFollow.y;
        }
    }

    public function resetScene() {
        if(scene != null) {
            scene.dispose();
        }
        
        scene = new h2d.Scene();
        camera = scene.camera;
        camera.anchorX = 0.5;
        camera.anchorY = 0.5;
        cameraFollow = null;

        for(entity in entities) {
            entity.destroy();
        }

        navigationGrids = [];
        renderables = new h2d.Layers(scene);
        ldtkEntityPrefabs = [];
        listenerFollow = null;
    }
    
    public function ldtkAddEntities(entities: Array<ldtk.Entity>, ?offset: Vector2): Array<Entity> {
        var entitiesAdded: Array<Entity> = [];
        for(entity in entities) {
            if(ldtkEntityPrefabs.exists(entity.identifier)) {
                var ent = addEntity(ldtkEntityPrefabs[entity.identifier]());
                var transform: Transform2D = cast ent.getSingleComponentOfType(Transform2D);
                if(transform != null) {
                    transform.position.set(entity.pixelX, entity.pixelY);
                    if(offset != null) {
                        transform.position.addMutate(offset);
                    }
                }
                entitiesAdded.push(ent);
            }
        }

        return entitiesAdded;
    }

    public function ldtkAddCollisionLayer(layer: ldtk.Layer_Tiles, ?tags: Array<String>, ?offset: Vector2, ?customShapes: Map<Int, Void->CollisionShape>) {
        var tileSize = layer.gridSize;
        for(i in 0...layer.cWid) {
            for(j in 0...layer.cHei) {
                var hasTile = layer.hasAnyTileAt(i, j);
                if(hasTile) {
                    var colTile = layer.getTileStackAt(i, j);
                    var org = new Vector2(i*tileSize, j*tileSize);
                    
                    var newShape: CollisionShape;
                    if(customShapes != null && customShapes.exists(colTile[0].tileId)) {
                        newShape = customShapes[colTile[0].tileId]();
                    }
                    else {
                        var verts: Array<Vector2> = [
                            new Vector2(),
                            new Vector2(tileSize - 1, 0),
                            new Vector2(tileSize - 1, tileSize - 1),
                            new Vector2(0, tileSize - 1)
                        ];
                        var staticColShape = new CollisionPolygon("Static");
                        staticColShape.setVerticies(verts);
                        
                        staticColShape.offset = org;
                        newShape = staticColShape;
                        
                    }
                    if(offset != null) {
                        newShape.offset.addMutate(offset);
                    }

                    if(tags != null) {
                        for(tag in tags) {
                            newShape.tags.push(tag);
                        }
                    }
                    collisionWorld.shapes.push(newShape);
                }
            }
        }
    }
}