part of javelin_game;

/**
 * Represents a prefab constructed out of a Json String.
 * This pref can be instatiated multiple times in the game.
 */
class Prefab {
  String _json;
  dynamic _blueprint;

  Prefab.fromJsonString(String this._json) {
  }

  parse() {
  	_blueprint =JSON.parse(_json);
  }
}
