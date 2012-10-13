
class ComponentSystem<T extends Component> {
  List<T> _componentPool;
  HandleSystem _handleSystem;

  ComponentSystem(this._componentPool, int numComponents) {
    _handleSystem = new HandleSystem(numComponents, 0);
  }

  Component createComponent(GameObject owner, [List params]) {
    // Not implemented yet.
    return null;
  }

  void destroyComponent(int handle) {
    // Not implemented yet.
    return;
  }

  Component getComponentWithHandle(int handle) {
    // Not implemented yet.
    return null;
  }
}
