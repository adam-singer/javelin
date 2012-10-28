

/**
 * Manages multiple component systems (for multiple types of components) for
 * a scene.
 * */
class ComponentManager {
  Map<String, ComponentSystem> _systems;

  /**
   * Creates a component of the specified type and attaaches it to the given
   * game object
   */
  Component createComponent(String type, GameObject owner, [List params]) {
    return getSystemForType(type).createComponent(owner, params);
  }

  /**
   * Destroys the given component.
   */
  void destroyComponent(Component component) {
    getSystemForType(component.type).destroyComponent(component);
  }

  /**
   * Returns the component system for the specified type.
   * Throws an ArgumentError if the type is not registered.
   */
  ComponentSystem getSystemForType(String type) {
    var s = _systems[type];
    if(s == null) {
      throw new ArgumentError('Unknown type: $type');
    }
    return s;
  }

  /**
   * Register a component [system] with [typeName].
   */
  void registerComponentSystem(String typeName, ComponentSystem system) {
    _systems[typeName] = system;
  }

  /**
   * Goes through the list of component systems and issues update signals.
   */
  void updateComponents(num timeDelta) {
  	// TODO: Priority rules? E.g. physics go first?
    // Yes, but I'm not sure how best to express it.
    // Could be as simple as N levels which comonent systems are binned in.
   	for (var system in _systems.getValues()) {
    	system.updateComponents(timeDelta);	//Have fun!
    }
  }
}
