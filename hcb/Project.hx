package hcb;

import hcb.comp.col.CollisionShape;
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

    public function new() {
        resetScene();
        renderables = new h2d.Layers(scene);
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
    }

    public function resetScene() {
        if(scene != null) {
            scene.dispose();
        }
        
        scene = new h2d.Scene();
        camera = scene.camera;
        camera.anchorX = 0.5;
        camera.anchorY = 0.5;

        for(entity in entities) {
            entity.destroy();
        }
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
                    
                    if(customShapes != null && customShapes.exists(colTile[0].tileId)) {

                    }
                    else {
                        var verts: Array<Vector2> = [
                            new Vector2(),
                            new Vector2(tileSize - 1, 0),
                            new Vector2(tileSize - 1, tileSize - 1),
                            new Vector2(0, tileSize - 1)
                        ];
                        var staticColShape = new hcb.comp.col.CollisionPolygon("Static");
                        staticColShape.setVerticies(verts);
                        
                        staticColShape.offset = org;
                        if(offset != null) {
                            staticColShape.offset.addMutate(offset);
                        }

                        if(tags != null) {
                            for(tag in tags) {
                                staticColShape.tags.push(tag);
                            }
                        }

                        collisionWorld.shapes.push(staticColShape);
                    }
                }
            }
        }
    }
}