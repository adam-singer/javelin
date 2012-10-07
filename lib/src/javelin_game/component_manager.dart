

/**
 * This is just a stub implementation.
 * */
class ComponentManager {

  Map<String, ComponentSystem> _systems;

  ComponentSystem get(String type) {
    var s = _systems[type];
    if(s == null) {
      s = new ComponentSystem([], 1000);  //TODO: Specify type and make this work.
      _systems[type] = s;
    }
    return s;
  }
}
