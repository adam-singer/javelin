part of javelin_game;

class Scene {
  TransformGraph _transformGraph;

  GameObject _root;
  GameObject get root => _root;

  Map<String, GameObject> _idMap;

  PropertyBag _properties;
  PropertyBag get properties => _properties;

  Scene(int maxGameObjects) {
  	// TODO: remove me once we have proper support for multiple scenes.
  	_transformGraph = new TransformGraph(maxGameObjects);
  	_idMap = new Map<String, GameObject>();
  	_root = new GameObject('root');
  	_registerGameObject(root, null);
  	_properties = new PropertyBag();
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
    if (parent != null) {
      // Can't have a parent from a different scene.
      assert(parent.scene == this);
    }

    if(go.id != null) {
      if (_idMap[go.id] != null) {
        throw 'Trying to register a second game object with the id "${go.id}" '
            'to this scene.';
      }

      _idMap[go.id] = go;
    }

    go._scene = this;
    go._parent = parent;

    if(go.id == 'root') {
      return null;
    }

    parent._children.add(go);
    assert(parent._children.contains(go));

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

    go._parent._children.remove(go);
    go._parent = null;
    go._scene = null;

     // TODO: Notify Spectre that the resource with go.handle is gone.
  }


  /**
   * Returns the game object with the specified id if owned by this scene.
   */
  GameObject getGameObjectWithId(String id) {
  	return _idMap[id];
  }

  // TODO: Tags for game objects.
}
