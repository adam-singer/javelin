part of javelin_game;

class ComponentSystem<T extends Component> {
  ComponentPool<T> _componentPool;
  List<T> _liveComponents;

  /**
   * Creates a component system which allocates components from [componentPool]
   */
  ComponentSystem(this._componentPool) {
    _liveComponents = new List<T>();
  }

  // TODO: Not implemeted yet.
  String get componentTypeName => "Implement me";

  /**
   * Allocates a new component and returns a reference to it.
   * Adds new component to update list.
   */
  Component createComponent(GameObject owner, [List params]) {
    T component = _componentPool.getFreeComponent();
    assert(component != null);
    _addToLiveComponents(component);
    return component;
  }

  /**
   * Marks the [component] as free. Removes [component] from update list.
   */
  void destroyComponent(Component component) {
    if (component == null) {
      return;
    }
    _removeFromLiveComponents(component);
    // Add component to the pool to be recycled.
    _componentPool.add(component);
    return;
  }

  /**
   * Updates all the components of this type
   */
  void updateComponents(num timeDelta) {
    for (var c in _liveComponents) {
      if (c.enabled && c.owner.enabled) {
        c.update(timeDelta);
      }
    }
  }

  void _addToLiveComponents(T component) {
    _liveComponents.add(component);
  }

  void _removeFromLiveComponents(T component) {
    final int index = _liveComponents.indexOf(component);
    final int last = _liveComponents.length-1;
    assert(index != -1);
    // Move last component into component's slot.
    _liveComponents[index] = _liveComponents[last];
    // Remove end of list.
    _liveComponents.removeLast();
  }
}
