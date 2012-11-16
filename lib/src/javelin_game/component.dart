part of javelin_game;

/**
 * Base class for all javelin components.
 *
 * A component adds functuonality to game objects.
 * Components are aggregated in game obejcts rather than extended, although
 * component class hierarchies are useful as well.
 */
class Component implements Serializable {

  // We need this until dart fully supports runtimeType
  // TODO: Implement using runtimeType.toString()?
  String _type;
  String get type => _type;

  // Won't receive update calls if set to false.
  bool enabled = true;

  GameObject _owner;
  GameObject get owner => _owner;

  PropertyMap _data = new PropertyMap();
  PropertyMap get data => _data;
  set data (Map<String, dynamic> value) {
    if(value is! PropertyMap) {
      value = new PropertyMap.from(value);
    }
    _data = value;
  }


  EventListenerMap get events => owner.events;
  Transform get transform => owner.transform;
  Scene get scene => owner.scene;

  // List of dependencies to be checked when this is initialized.
  Set<String> _componentDependencies = new Set<String>();

  // List of arguments that were used to construct this object (parameters to
  // the init() function. Stored so we can serialize them and reconstruct this
  // object).
  PropertyList _initData;

  Component() {
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
    for(var component in _componentDependencies) {
      if(owner.getComponent(component) == null) {
        throw 'Failed component dependency test. Component: ${type} requires'
            'at least component of type ${component}';
        return false;
      }
    }
    return true;
  }

  /**
   * Serialize.
   */
  String toJson() {
    SceneDescriptor.serializeComponent(this);
  }

  /**
   * Deserialize.
   */
  void fromJson(dynamic json) {
    throw 'Trying to deserialize a Component by calling fromJson() on it. '
    'Components are special. Use '
    'SceneDescriptor.attachComponentFromPrototype() instead.';
  }
}
