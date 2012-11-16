part of javelin_game;

class SceneDescriptor {

  /**
   * Serializes a GameObject.
   */
  static String serializeGameObject(GameObject go,
                                    [bool serializeChildren = true]) {
    var buffer = new StringBuffer();
    buffer.add('{');

    // Id:
    if (go.id != null) {
      buffer.add('"id":"${go.id}",');
    }

    // Data:
    buffer.add('"data":${go.data.toJson()},');

    // Components:
    buffer.add('"components":[');
    var first = true;
    for (var component in go.getAllComponents()) {
      first ? first = false : buffer.add(',');
      buffer.add(serializeComponent(component));
    }
    buffer.add('],');

    // Children:
    if (serializeChildren) {
      buffer.add('"children":[');
      var first = true;
      for (var child in go.children) {
        first ? first = false : buffer.add(',');
        buffer.add(serializeGameObject(child));
      }
      buffer.add(']');
    }

    buffer.add('}');
    return buffer.toString();
  }

  /**
   * Serializes a Component.
   */
  static String serializeComponent(Component component) {
    var mirror = reflect(component);
    var buffer = new StringBuffer();
    buffer.add('{');
    buffer.add('"type":"${mirror.type.qualifiedName}",');
    if (component._initData != null) {
      buffer.add('"initData":${component._initData.toJson()},');
    }
    buffer.add('"data":${component.data.toJson()}');
    buffer.add('}');
    return buffer.toString();
  }

  /**
   * Constructs a game object given a prototype and returns it.
   */
  static GameObject createGameObjectFromPrototype(dynamic prototype) {
    var id = prototype['id'];
    var go = new GameObject(id);

    // Data:
    go.data = prototype['data'];

    // Components:
    var components = prototype['components'];
    for (var componentProto in components) {
      attachComponentFromPrototype(componentProto, go);
    }

    // Children:
    var children = prototype['children'];
    for (var childProto in children) {
      var child = createGameObjectFromPrototype(childProto);
      go.addChild(child);
    }
    return go;
  }

  /**
   * Given a component prototype, creates a component and attaches it to
   * the provided game object.
   */
  static GameObject attachComponentFromPrototype(dynamic componentPrototype,
                                                 GameObject go) {
    var type = componentPrototype['type'];
    var initData = componentPrototype['initData'];
    var data = componentPrototype['data'];

    // Since the scene has not been set, the component won't be initalized yet,
    // so its safe to assign data after this call.
    var component = go.attachComponent(type, initData);
    component.data = data;
  }

  static ClassMirror findClass(String qualifiedName) {
    for (var lib in currentMirrorSystem().libraries.values) {
      for (var clazz in lib.classes.values) {
        if (clazz.qualifiedName == qualifiedName) {
          return clazz;
        }
      }
    }
  }


}
