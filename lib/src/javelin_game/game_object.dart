class GameObjectComponents {
  ComponentSystem _system;

  Map<String, List<int>> _componentLists;
  Map<int, String> _componentTypes;

  GameObjectComponents(ComponentSystem this._system) {
    _componentLists = new Map();
    _componentTypes = new Map();
  }

  void attachComponent(String type, int handle) {
    List<int> list = _componentLists[type];
    if (list == null) {
      list = new List<int>();
      _componentLists[type] = list;
    }
    list.add(handle);
    _componentTypes[handle] = type;
  }

  void detachComponent(String type, int handle) {
    List<int> list = _componentLists[type];
    int index = list.indexOf(handle, 0);
    assert(index != -1);
    list.removeAt(index);
  }

  Component getComponent(String type) {
    List<int> list = _componentLists[type];
    if (list == null || list.length == 0) {
      return null;
    }
    return _system.get(type).withHandle(list[0]);
  }

  List<Component> getComponents(String type) {
    List<int> list = _componentLists[type];
    if (list == null || list.length == 0) {
      return new List<Component>();
    }
    else {
      var system = _system.get(type);
      List<Component> output = [];
      for (var i in list) {
        var component = system.withHandle(i);
        assert(component != null);
        output.add(component);
      }
      return output;
    }
  }

  Component getComponentWithHandle(int handle) {
    String type = _componentTypes[handle];
    if (type == null) {
      return null;
    }
    List<int> list = _componentLists[type];
    if (list == null || list.length == 0) {
      return null;
    }
    var system = _system.get(type);
    for (var i in list) {
      if(i == handle) {
        return system.withHandle(i);
      }
    }
    return null;
  }

  void destroyAllComponents() {
    // Destroy every component we have, be extra careful to not modify the
    // lists of components as we iterate them.
    var listOfLists = new List.from(_componentLists);
    for (var list in List.from(listOfLists)) {
      for (var component in list) {
        destroyComponent(component);
      }
    }
  }
}

class GameObject {

  int _handle;
  int get handle => _handle;

  String _id;
  String get id => _id;

  GameObject _parent;
  GameObject get parent => _parent;

  Set<GameObject> _children;
  Set<GameObject> get children => _children;

  PropertyBag _properties;
  PropertyBag get properties => _properties;

  EventListenerMap _events;
  EventListenerMap get events => events;

  Scene _scene;
  Scene get scene => _scene;

  // Static access for common components.

  Transform _transform;
  Transform get transform => _transform;

  // Public properties:

  // Set to false to prevent this from updating.
  bool enabled = true;

  //TODO: actuavated / enabled mechanism?

  // Private properties

  GameObjectComponents _components;

  /// Contructor.
  GameObject([String this._id]) {

    // TODO: Get a handle from Spectre and store it on:
    // _handle

    parent = null;
    children = new Set<GameObject>();
    properties = new PropertyBag();
    components = new GameObjectComponents();
    events = new EventListenerMap(this);

    // Initialize the transform
    _transform = scene.components.createComponent('Transform', this);

  }

  Component getComponent(String type) {
    return _components.getComponent(type);
  }

  List<Component> getComponents(String type) {
    return _components.getComponents(type);
  }

  Component getComponentWithHandle(int handle) {
    return _components.getComponentWithHandle(handle);
  }

  Component attachComponent(String type, [List params]) {
    var system = _scene.components.get(type);
    int handle = system.createComponent(this, params);
    _components.attachComponent(type, handle);
    return system.withHandle(handle);
  }

  void destroyComponent(Component component) {
    _components.detachComponent(component.type, component.handle);
    var system = _scene.components.get(type);
    system.destroyComponent(handle);
  }

  /// Destroys this game obejct. Do not call this.
  /// Call Scene.destroyGameObject instead.
  void _destroyAllComponents() {
    _components._destroyAllComponents();
  }
}
