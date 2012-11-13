part of javelin_state;

class SceneDescriptor {

  String describeGameObject(GameObject go, [bool describeChildren = true]) {
    var buffer = new StringBuffer();
    buffer.add('{');
    buffer.add(describeComponentsForGameObject(go));

    buffer.add('"properties":${go.data.toJson()}');

    if (describeChildren) {
      buffer.add('"children":[');
      var first = true;
      for (var child in go.children) {
        first ? first = false : buffer.add(',');
        buffer.add(describeGameObject(child));
      }
      buffer.add(']');
    }

    buffer.add('}');
    return buffer.toString();
  }

  String describeComponentsForGameObject(GameObject go) {
    var buffer = new StringBuffer();
    buffer.add('"components":[');
    var first = true;
    for (var component in go.getAllComponents()) {
      first ? first = false : buffer.add(',');
      buffer.add(describeComponent(component));
    }
    buffer.add(']');
    return buffer.toString();
  }

  String describeComponent(Component component) {
    var mirror = reflect(component);
    var buffer = new StringBuffer();
    buffer.add('{');
    buffer.add('"type":"${mirror.type.qualifiedName}"');
    buffer.add('"content":"${component.toJson()}"');
    buffer.add('}');
    return buffer.toString();
  }

}
