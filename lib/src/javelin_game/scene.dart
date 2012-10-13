class Scene {

  // TODO: remove me once we have proper support for multiple scenes.
  static Scene _instance;
  static Scene get current => _instance;  // Replace by Application.currentScene;

  GameObject _root;
  GameObject get root => _root;

  Map<String, int> _idMap;
  Map<int, GameObject> _handleMap;

  ComponentManager _components;
  ComponentManager get components => _components;

  Scene() {
  	// TODO: remove me once we have proper support for multiple scenes.
  	_instance = this;

  	_idMap = new Map<String, int>();
  	_handleMap = new Map<int, GameObject>();
  	_root = new GameObject('root');
  	registerGameObject(root, null);
  }

  /// Registers a game object with the scene.
  void registerGameObject(GameObject go, GameObject parent) {
    if(go.id != null) {
      assert(_idMap[go.id] == null);
      _idMap[go.id] = go.handle;
    }
    assert(_handleMap[go.handle] == null);
    _handleMap[go.handle] = go;

    go._scene = this;
    go._parent = parent;

    if(go.id == 'root') {
      return;
    }

    assert(parent.children.contains(go));
    parent.children.add(go);

    go.checkDependencies();
    go._initializeComponents();
  }

  /// Registers a game object with the scene.
  void reparentGameObject(GameObject go, GameObject parent) {
    assert(go != root);  // Cannot reparent root!
    assert(_handleMap[go.handle] != null);

    assert(go.parent.children.contains(go));
    go.parent.children.remove(go);

    go._parent = parent;
    assert(!parent.children.contains(go));
    parent.children.add(go);

    //TODO: Reparenting has implications on the Transform. Do math!
  }

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

  GameObject getGameObjectWithHandle(int handle) {
  	return _handleMap[handle];
  }

  GameObject getGameObjectWithId(String id) {
  	int handle = _idMap[id];
  	if(handle == null) {
  	  return null;
  	}
  	return getGameObjectWithHandle(handle);
  }

  // TODO: Tags for game objects.
}
