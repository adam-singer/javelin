
class Game {
  static Scene _instance;
  static Scene get current => _instance;
  static set current(Scene scene) => _instance = scene;

  static ComponentManager _componentManager;
  static ComponentManager get componentManager => _componentManager;

  static init() {
    _instance = null;
    _componentManager = new ComponentManager();
  }
}
