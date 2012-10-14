
class ComponentSystem<T extends Component> {
  List<T> _componentPool;
  HandleSystem _handleSystem;

  ComponentSystem(this._componentPool, int numComponents) {
    _handleSystem = new HandleSystem(numComponents, 0);
  }

  // TODO: Not implemeted yet.
  String get componentTypeName => "Implement me";

  Component createComponent(GameObject owner, [List params]) {
    // TODO: Not implemented yet.
    // Do not call init on it. The owner will do that.
    return null;
  }

  void destroyComponent(int handle) {
    // TODO: Not implemented yet.
    // Do not call free on it. The owner will do that.
    return;
  }

  Component getComponentWithHandle(int handle) {
    // TODO: Not implemented yet.
    return null;
  }

  /**
   * Updates all the components of this type
   * */
  void updateComponents(num timeDelta) {
    for (var c in _componentPool) {
      if(c.enabled && c.owner.enabled) {
        c.update(timeDelta);
      }
    }
  }
}
