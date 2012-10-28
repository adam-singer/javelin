
class Component {

  // We need this until dart fully supports runtimeType
  // TODO: Implement using runtimeType.toString()?
  String _type;
  String get type => _type;

  // Won't receive update calls if set to false.
  bool enabled = true;

  GameObject _owner;
  GameObject get owner => _owner;

  //Expose this properties for easy access.
  PropertyBag get properties => owner.properties;
  EventListenerMap get events => owner.events;
  Transform get transform => owner.transform;
  Scene get scene => owner.scene;

  // List of dependencies to be checked when this is initialized.
  Set<String> _componentDependencies = new Set<String>();

  Component() {
  }

  void _attach(GameObject owner) {
    this.owner = owner;
  }

  void _destroy() {
    owner = null;
  }

  void init([List params]) {
  }

  void update(num timeDelta) {
  }

  void free() {
  }

  /**
   *  Enforces that a component of type type must be present on the owner
   *  of this component.
   */
  void requireComponent(String type) {
    // We are not initialized yet. Just store this so we can check it later.
    if (_componentDependencies.contains(type) == false) {
      _componentDependencies.add(type);
    }
  }

  /**
   * Checks that all the dependencies on other components are satisfied.
   */
  bool checkDependencies() {
    for(var c in _componentDependencies) {
      if(owner.getComponent(c) == null) {
        assert(false);
        return false;
      }
    }
    return true;
  }
}
