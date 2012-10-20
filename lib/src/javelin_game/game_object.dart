class ComponentList {
  Map<String, List<int>> _componentLists;
  Map<int, String> _componentTypes;

  // List of components to initialize (in case they are added before this
  // game object is added to the scene). Maps Component handles to lists
  // of arguments to be passed to their init function.
  Map<int, List> _toInitialize = null;

  GameObject _owner;

  //TODO: Remove all the references to Scene.current here.
  ComponentList(this._owner) {
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
    return _owner.scene.componentManager.getComponentWithHandle(list[0]);
  }

  List<Component> getComponents([String type='Component']) {
    List<int> list = _componentLists[type];
    if (list == null || list.length == 0) {
      return new List<Component>();
    }
    else {
      var system = _owner.scene.componentManager.getSystemForType(type);
      List<Component> output = [];
      for (var i in list) {
        var component = system.getComponentWithHandle(i);
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
    var system = _owner.scene.componentManager.getSystemForType(type);
    for (var i in list) {
      if(i == handle) {
        return system.getComponentWithHandle(i);
      }
    }
    return null;
  }

  void destroyAllComponents() {
    // Destroy every component we have, be extra careful to not modify the
    // lists of components as we iterate them.
    for (var list in _componentLists.getValues()) {
      for (var component in new List.from(list)) {
        _owner.destroyComponent(component);
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

  //TODO: activated / enabled mechanism?

  // Private properties

  ComponentList _components;

  /// Contructor.
  GameObject([String this._id]) {

    // TODO: Get a handle from Spectre and store it on:
    // _handle

    parent = null;
    children = new Set<GameObject>();
    properties = new PropertyBag();
    _components = new ComponentList(this);
    events = new EventListenerMap(this);

    // Initialize the transform
    _transform = attachComponent('Transform');

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
    Component c = _scene.componentManager.createComponent(type, this, params);
    _components.attachComponent(type, c.handle);

    // 2 cases, maybe we are already registered in the scene, in which case we
    // can initialize the component right away. Otherwise, lets wait for the
    // scene to notify us that we are added.
    if(scene != null) {
      c.init(params);
      c.checkDependencies();
      return c;
    }
    else {
      _components._toInitialize[c.handle] = params;
      return c;
    }
  }

  void destroyComponent(Component component) {
    component.free();
    _components.detachComponent(component.type, component.handle);
    _scene.componentManager.destroyComponent(component);
    checkDependencies();
  }

  void addChild(GameObject go) {
    if(children.contains(go)) {
      return;
    }

    if(go.parent != null) {
      scene.reparentGameObject(go, this);
    }
    else {
      scene.registerGameObject(go, this);
    }
  }

  /**
   * Checks that all the components' dependencies on other components
   * are satisfied.
   */
  bool checkDependencies() {
    for(var c in _components.getComponents()) {
      c.checkDependencies();
    }
  }

  /**
   * If there are components added but not yet initialized, this will initialize
   * them. Called by the scene when a game object is registered with it.
   * Do not manually call this.
   */
  void _initializeComponents() {
    if(_components._toInitialize != null){
      for(var handle in _components._toInitialize.getKeys()) {
        var c = getComponentWithHandle(handle);
        var params = _components._toInitialize[handle];
        c.init(params);
      }
    }
  }

  /// Do not manually call this. Call Scene.destroyGameObject instead.
  void _destroyAllComponents() {
    _components.destroyAllComponents();
  }
}
