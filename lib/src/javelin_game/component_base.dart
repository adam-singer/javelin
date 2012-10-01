
class ComponentBase {
  int handle;
  GameObject owner;
  PropertyBag properties;

  ComponentBase() {
    properties = new PropertyBag();
  }

  void attach(this.handle, this.owner) {
  }

  void detach() {
    handle = null;
    owner = null;
    properties.clear();
  }

  void update() {
  }
}
