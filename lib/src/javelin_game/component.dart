part of javelin_game;

/**
 * Base class for all javelin components.
 *
 * A component adds functuonality to game objects.
 * Components are aggregated in game obejcts rather than extended, although
 * component class hierarchies are useful as well.
 */
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
        throw 'Failed component dependency test. Component: ${type} requires'
            'at least component of type ${c}';
        return false;
      }
    }
    return true;
  }

  bool _metadataCopied = false;

  void initializeWithMetadata(dynamic data) {
    InstanceMirror myself = reflect(this);
    InstanceMirror metadata = reflect(data);

    var futures1 = [];
    var futures2 = [];

    for (var memberName in metadata.type.members.keys) {
      var member = metadata.type.members[memberName];
      if (member is VariableMirror) {
        if (myself.type.members.containsKey(memberName)) {
          var getValueFuture = metadata.getField(memberName);
          futures1.add(getValueFuture);
          getValueFuture.then((valueMirror) {
            var setValueFuture =
                myself.setField(memberName, valueMirror.reflectee);
            futures2.add(setValueFuture);
          });
        }
      }
    }

    var almostThere = Futures.wait(futures1);
    almostThere.then((list) {
      Futures.wait(futures2).then((anotherList) => _metadataCopied = true);
    });
  }
}
