

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
    destroyComponentWithHandle(component.handle, component.type);
  }

  /**
   * Destroys a component with the given handle. If the type is provided the
   * search is done faster.
   *
   */
  void destroyComponentWithHandle(int handle, [String type]) {
  	if (type == null ) {
  	  type = _findComponentWithHandle(handle).type;
  	}
  	getSystemForType(type).destroyComponent(handle);
    return;
  }

  /**
   * Returns a component with the given handle. If the type is provided, this
   * operation is done faster.
   */
  Component getComponentWithHandle(int handle, [String type]) {
    if (type == null ) {
      return _findComponentWithHandle(handle);
    }
    return getSystemForType(type).getComponentWithHandle(handle);
  }

  /**
   * Returns the component system for the secidied type.
   */
  ComponentSystem getSystemForType(String type) {
    var s = _systems[type];
    if(s == null) {
      s = new ComponentSystem([], 1000);  //TODO: Specify type and make this work.
      _systems[type] = s;
    }
    return s;
  }

  /**
   * Goes through the list of component systems and issues update signals.
   */
  void updateComponents(num timeDelta) {
  	// TODO: Priority rules? E.g. physics go first?
   	for (var system in _systems.getValues()) {
    	system.updateComponents(timeDelta);	//Have fun!
    }
  }

  /**
   * Iterates through all of the component systems util it finds a component
   * with the specified handle. This is a slow operation.
   * It is only called by other methods in this function when the type of
   * the component is unkown.
   */
  Component _findComponentWithHandle(int handle) {
    for (var system in _systems.getValues()) {
      var c = system.getComponentWithHandle(handle);
      if(c != null) {
        return c;
      }
    }
    return null;
  }
}
