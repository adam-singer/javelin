/**
 * Defines an scriptable component.
 *
 * All custom components must extend this class.
 */
class ScriptComponent extends Component {

  ScriptComponent(String type) : super() {
    _type = type;
  }

  void init([List params]) {
  }

  void update(num timeDelta) {
  }

  void free() {
  }
}