class Scene {

  // TODO: remove me once we have proper support for multiple scenes.
  static Scene _instance;
  static Scene get current => _instance; // Replace by Application.currentScene

  GameObject _root;
  GameObject get root => _root;

  Map<String, int> _idMap;
  Map<int, GameObject> _handleMap;

  ComponentManager _componentManager;
  ComponentManager get componentManager => _componentManager;

  PropertyBag _properties;
  PropertyBag get properties => _properties;

  Scene() {
  	// TODO: remove me once we have proper support for multiple scenes.
  	_instance = this;

  	_idMap = new Map<String, int>();
  	_handleMap = new Map<int, GameObject>();
  	_root = new GameObject('root');
  	_registerGameObject(root, null);

  	properties = new PropertyBag();
  }

  /**
   * Registers a game object with the scene.
   * The second parameter indicates the parent of the game object.
   * Returns null unless 'initializeComponents' is set to false,
   * in wich case it returns a list of game objects that need to be initialized.
   * This mechanism is used internally calling this function recursively to
   * register children of the game object we are trying to register.
   * This ensures that components don't get initialized before all of the
   * children of their owner have been added.
   */
  Set<GameObject> _registerGameObject(GameObject go, GameObject parent,
                          [bool initializeComponents = true]) {
    assert(parent.scene == this);

    if(go.id != null) {
      assert(_idMap[go.id] == null);
      _idMap[go.id] = go.handle;
    }
    assert(_handleMap[go.handle] == null);
    _handleMap[go.handle] = go;

    go._scene = this;
    go._parent = parent;

    if(go.id == 'root') {
      return null;
    }

    assert(parent._children.contains(go));
    parent._children.add(go);

    // If the game object has children that need to be registred, do that
    // recursivey.
    if (go._childrenToRegister != null) {
      Set<GameObject> toInitialize = new Set.from(go._childrenToRegister);

      // First register all children recursively and collect a list of
      // game objects to initialize.
      for (var child in go._childrenToRegister) {
        toInitialize.addAll(_registerGameObject(child, go, false));
      }

      // If we are not the first call on the stack, return a list of game
      // objects that need to be initialized.
      if (!initializeComponents) {
        return toInitialize;
      }
      else {
        // Initialize everything at once.
        for (var child in toInitialize) {
          child.checkDependencies();
          child._initializeComponents();
        }
      }
    }

    go.checkDependencies();
    go._initializeComponents();
    return null;
  }

  /// Registers a game object with the scene.
  void _reparentGameObject(GameObject go, GameObject parent) {
    assert(go != root);  // Cannot reparent root!
    assert(_handleMap[go.handle] != null);

    assert(go.parent.children.contains(go));
    go.parent.children.remove(go);

    go._parent = parent;
    assert(!parent.children.contains(go));
    parent.children.add(go);

    //TODO: Reparenting has implications on the Transform. Do math!
  }

  /// Destroys a game object owned by this scene.
  void destroyGameObject(GameObject go) {
  	// Never destroy root. That should never happen.
  	assert(go != root);

  	//Destroy it's children, recursively
  	for (var child in go.children) {
  		destroyGameObject(child);
  	}

  	// Note: People may have callbacks (free()) set up. Those will trigger here.
  	// Make sure that we still have a valid Game Obejct when we make this call.
  	go._destroyAllComponents();

    if(go.id != null) {
      assert(_idMap[go.id] != null);
      _idMap[go.id] = null;
    }
    assert(_handleMap[go.handle] != null);
    _handleMap[go.handle] = null;

    go._parent = null;

     // TODO: Notify Spectre that the resource with go.handle is gone.
  }

  /**
   * Returns the game object that has the passed handle, if owned by this
   * scene.
   */
  GameObject getGameObjectWithHandle(int handle) {
  	return _handleMap[handle];
  }

  /**
   * Returns the game object with the specified id if owned by this scene.
   */
  GameObject getGameObjectWithId(String id) {
  	int handle = _idMap[id];
  	if(handle == null) {
  	  return null;
  	}
  	return getGameObjectWithHandle(handle);
  }

  // TODO: Tags for game objects.
}
