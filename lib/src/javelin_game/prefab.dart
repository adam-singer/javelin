part of javelin_game;

/**
 * Represents a Game Object blueprint constructed out of a Json String,
 * including its components, data and children. A whole scene can be stored
 * as a single prefab.
 * This prefab can be instatiated multiple times in the game.
 */
class Prefab {
  dynamic _prototype;

  /**
   * Contructs a Prefab from a Json String coming from a GameObject.toJson()
   * call.
   */
  Prefab.fromJsonString(String json) {
    _prototype = JSON.parse(json);
  }

  /**
   * Constructs a Prefab from a GameObject.
   */
  factory Prefab.fromGameObject(GameObject go) {
    String json = go.toJson();
    return new Prefab.fromJsonString(json);
  }

  /**
   * Instantiates this prefab.
   */
  GameObject instantiate() {
    return SceneDescriptor.createGameObjectFromPrototype(_prototype);
  }
}
