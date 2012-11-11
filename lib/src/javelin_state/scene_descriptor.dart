part of javelin_state;

class SceneDescriptor {

  String describeGameObject(GameObject go, [bool describeChildren = true]) {
    var buffer = new StringBuffer();
    buffer.add('{');
    buffer.add(describeComponentsForGameObject(go));

    // TODO: describe property bag.

    if (describeChildren) {
      var first = true;
      for (var child in go.children) {
        if (first) {
          first = false;
        }
        else {
          buffer.add(',');
        }
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
      if (first) {
        first = false;
      }
      else {
        buffer.add(',');
      }
      buffer.add(describeComponent(component));
    }
    buffer.add(']');
    return buffer.toString();
  }

  String describeComponent(Component component) {
    var mirror = reflect(component);
    var buffer = new StringBuffer();
    buffer.add('{');
    buffer.add('"type":');
    buffer.add('"${mirror.type.simpleName}"');
    // TODO: describe component state.
    buffer.add('}');
    return buffer.toString();
  }

}
