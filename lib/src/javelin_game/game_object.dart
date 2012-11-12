part of javelin_game;

class GameObject {
  String _id;
  String get id => _id;

  GameObject _parent;
  GameObject get parent => _parent;

  Set<GameObject> _children;
  Set<GameObject> get children => _children;

  PropertyMap _data;
  PropertyMap get data => _data;
  set data (Map<String, dynamic> value) {
    if(!value is PropertyMap) {
      value = new PropertyMap.from(value);
    }
    _data = value;
  }

  EventListenerMap _events;
  EventListenerMap get events => _events;

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

  Set<Component> _components;

  Map<Component, List> _componentsToInitialize;

  Set<GameObject> _childrenToRegister;

  /// Contructor.
  GameObject([String this._id]) {
    _parent = null;
    _children = new Set<GameObject>();
    _childrenToRegister = new Set<GameObject>();
    _data = new PropertyMap();
    _components = new Set();
    _events = new EventListenerMap(this);
    //TODO(johnmccutchan): Initialize the transform
  }

  /**
   * Returns the first component of the specified type.
   * Interfaces and base clases may be used, unless exactType is true.
   */
  Component getComponent(String type, [bool exactType = false]) {
    for(var component in _components) {
      // TODO: Replace by an actual type check.
      if(component._type == type) {
        return component;
      }
    }
    return null;
  }

  /**
   * Returns all the components of the specified type.
   * Interfaces and base clases may be used, unless exactType is true.
   */
   List<Component> getComponents(String type, [bool exactType = false]) {
    var list = [];
    for(var component in _components) {
      // TODO: Replace by an actual type check.
      if(component._type == type) {
        list.add(component);
      }
    }
    return list;
  }

   /**
    * Returns a list of all the components attached to this game object.
    */
   List<Component> getAllComponents() {
    return new List.from(_components);
  }

  /**
   * Attaches a component of the given type to this game object.
   * An optional list of parameters may be supplied, these parameters will be
   * sent as arguments to the component's init() function.
   */
  Component attachComponent(String type, [List params]) {
    var component = Game.componentManager.createComponent(type, this, params);
    component._owner = this;
    _components.add(component);
    // 2 cases, maybe we are already registered in the scene, in which case we
    // can initialize the component right away. Otherwise, lets wait for the
    // scene to notify us that we are added.
    if(scene != null) {
      component.init(params);
      component.checkDependencies();
      return component;
    }
    else {
      if(_componentsToInitialize == null) {
        _componentsToInitialize = new Map();
      }
      _componentsToInitialize[component] = params;
      return component;
    }
  }

  /**
   * Destroys a component attached to this game object.
   * This component cannot be used on other game objects.
   * References to the destroyed component are now invalid and they will not
   * be set to null because the Component is part of an object pool.
   * */
  void destroyComponent(Component component) {
    if(!_components.contains(component)) {
      throw 'Trying to remove a component (${component.runtimeType}) from a '
          'game object that does not own it.';
    }

    component.free();
    component._owner = null;
    component.enabled = false;
    _components.remove(component);
    Game.componentManager.destroyComponent(component);
    checkDependencies();
  }

  /**
   * Adds a new child to this game object.
   * Reparenting and scene registration are managed automatically.
   * Returns the game object that was added (for chaining purpuses).
   */
  GameObject addChild(GameObject go) {
    if (go.scene != null) {
      // Make sure we are not adding game object from a different scene.
      assert(go.scene == scene);
    }

    // Already added.
    if (_children.contains(go) || _childrenToRegister.contains(go)) {
      return go;
    }

    if (scene == null ) {
      // We are not registred yet.
      if (_childrenToRegister == null) {
        _childrenToRegister = new Set();
      }
      if (!_childrenToRegister.contains(go)) {
        _childrenToRegister.add(go);
      }
    }
    else {
      if (go.parent != null) {
        scene._reparentGameObject(go, this);
      }
      else {
        scene._registerGameObject(go, this);
      }
    }
    return go;
  }

  /**
   * Checks that all the components' dependencies on other components
   * are satisfied.
   */
  bool checkDependencies() {
    for(var component in _components) {
      component.checkDependencies();
    }
  }

  /**
   * If there are components added but not yet initialized, this will initialize
   * them. Called by the scene when a game object is registered with it.
   * Do not manually call this.
   */
  void _initializeComponents() {
    if(_componentsToInitialize != null){
      for(var component in _componentsToInitialize.keys) {
        var params = _componentsToInitialize[component];
        component.init(params);
      }
    }
  }

  /// Do not manually call this. Call Scene.destroyGameObject instead.
  void _destroyAllComponents() {
    // Destroy every component we have, be extra careful to not modify the
    // lists of components as we iterate them.
    for (var component in new List.from(_components)) {
      destroyComponent(component);
      _componentsToInitialize = null;
    }
  }
}
