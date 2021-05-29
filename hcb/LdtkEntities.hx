package hcb;

import VectorMath;

class LdtkEntities {
    public static var ldtkEntityPrefabs(default, null): Map<String, ldtk.Entity->Array<hcb.comp.Component>> = [];
    // ^ The keys in this map are the ldtk entity identifiers

    public static function ldtkAddEntities(room: Room, entities: Array<ldtk.Entity>, layer: Int = 0, ?offset: Vec2): Array<Entity> {
        var entitiesAdded: Array<Entity> = [];
        for(entity in entities) {
            var newEntity = ldtkAddEntity(room, entity, layer, offset);
            if(newEntity != null) {
                entitiesAdded.push(newEntity);
            }
        }

        return entitiesAdded;
    }

    public static function ldtkAddEntity(room: Room, entity: ldtk.Entity, layer: Int = 0, ?offset: Vec2): Entity {
        if(ldtkEntityPrefabs.exists(entity.identifier)) {
            // * Getting the position of the entity
            var pos: Vec2 = vec2(entity.pixelX, entity.pixelY);
            if(offset != null) {
                pos += offset;
            }

            // * Adding the entity
            var newEntity = new Entity(ldtkEntityPrefabs[entity.identifier](entity), pos, layer);
            
            room.addEntity(newEntity);
            return newEntity;
        }
        return null;
    }
}