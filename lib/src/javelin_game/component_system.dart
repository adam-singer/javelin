
class ComponentSystem<T extends Component> {
  List<T> _componentPool;
  HandleSystem _handleSystem;

  ComponentSystem(this._componentPool, int numComponents) {
    _handleSystem = new HandleSystem(numComponents, 0);
  }
}
