part of javelin_game;

typedef Component componentConstructor();

/**
 * A pool of [E] components.
 *
 * Must be constructed with a componentConstructor function which must
 * return a free instance of [E] when called.
 *
 * Can be initialized with a list of already constructed components.
 *
 * Components can be added by calling [add].
 *
 * A component can be removed from the pool by calling [getFreeComponent].
 */
class ComponentPool<E extends Component> {
  List<E> _freeList;
  componentConstructor _constructor;

  /**
   * Construct an empty component pool
   */
  ComponentPool(this._constructor) {
    _freeList = new List<E>();
  }

  /**
   * Construct a component pool primed with [freeList] components.
   */
  ComponentPool.fromList(this._constructor, List<E> freeList) {
    _freeList = new List<E>();
    freeList.forEach((f) {
      _freeList.add(f);
    });
    freeList.clear();
  }

  /**
   * Get the next free component or contruct a new instance of [E].
   */
  E getFreeComponent() {
    if (_freeList.length > 0) {
      return _freeList.removeLast();
    }
    return _constructor();
  }

  /**
   * Add a component to the component pool's free list.
   */
  void add(E component) {
    _freeList.add(component);
  }
}
