
class ComponentSystem<T extends Component> {
  List<T> _componentPool;
  HandleSystem _handleSystem;

  /**
   * Creates a component system which allocates components from [componentPool]
   */
  ComponentSystem(this._componentPool) {
    _handleSystem = new HandleSystem(_componentPool.length, 0);
  }

  // TODO: Not implemeted yet.
  String get componentTypeName => "Implement me";

  /** 
   * Allocates a new component and returns the handle to it.
   */
  int createComponent(GameObject owner, [List params]) {
    int handle = _handleSystem.allocateHandle(0x0);
    if (handle == Handle.BadHandle) {
        // We have exhausted our pool.
        // TODO: Report this somehow.
        return null;
    }
    int index = Handle.getIndex(handle);
    Component comp = _componentPool[index];
    assert(comp != null);
    return comp;
  }

  /**
   * Marks the component associated with [handle] as available.
   */
  void destroyComponent(int handle) {
    if (handle == 0) {
      return;
    }
    if (_handleSystem.validHandle(handle) == false) {
      // TODO: Report this somehow.
      return;
    }
    _handleSystem.freeHandle(handle);
    // NOTE: createComponent could return a non-"free"
    // component because the handle is free.
    return;
  }

    
  /**
   * Returns the component associated with [handle] or null.
   */
  Component getComponentWithHandle(int handle) {
    if (handle == 0) {
      return null;
    }
    if (_handleSystem.validHandle(handle) == false) {
      // TODO: Report this somehow.
      return null;
    }
    int index = Handle.getIndex(handle);
    T component = _componentPool[index];
    if (component == null) {
      // TODO: Report this somehow.
      return null;
    }
    return component;
  }

  /**
   * Updates all the components of this type
   */
  void updateComponents(num timeDelta) {
    for (var c in _componentPool) {
      if(c.enabled && c.owner.enabled) {
        c.update(timeDelta);
      }
    }
  }
}
