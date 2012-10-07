
class Scene {

  // TODO: remove me once we have proper support for multiple scenes.
  static Scene _instance;
  static Scene get current => _instance;  // Replace by Application.currenScene;

  GameObject _root;
  GameObject get root => _root;

  Map<String, int> _idMap;
  Map<int, GameObject> _handleMap;

  Scene() {
  	// TODO: remove me once we have proper support for multiple scenes.
  	_instance = this;

  	_idMap = new Map<String, int>();
  	_handleMap = new Map<int, GameObject>();
  	_root = new GameObject('root');
  	_registerGameObject(root);
  }

  /// Registers a game object with the scene.
  /// This should be called by GameObject.addChild only.
  void _registerGameObject(GameObject go) {
    go._scene = this;

    if(go.id != null) {
      assert(_idMap[go.id] == null);
      _idMap[go.id] = go;
    }
    assert(_handleMap[go.handle] == null);
    _handleMap[go.handle] = go;
  }

  void destroyGameObject(GameObject go) {
  	// Never destroy root. That should never happen.
  	assert(go != null);

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
}
