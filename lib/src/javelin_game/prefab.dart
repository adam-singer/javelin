part of javelin_game;

/**
 * Represents a Game Object blueprint constructed out of a Json String,
 * including its components, data and children. A whole scene can be stored
 * as a single prefab.
 * This prefab can be instatiated multiple times in the game.
 */
class Prefab {
  dynamic _prototype;

  Prefab.fromJsonString(String json) {
    _prototype = JSON.parse(json);
  }

  Prefab.fromJsonPrototype(dynamic this._prototype);

  /**
   * Instantiates this prefab.
   */
  GameObject instantiate() {
    return SceneDescriptor.createGameObjectFromPrototype(_prototype);
  }
}
