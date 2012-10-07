
class Component {

  int _handle;
  int get handle => _handle;

  // We need this until dart fully supports runtimeType
  String _type;
  String get type => _type;

  GameObject _owner;
  GameObject get owner => _owner;

  //Expose this properties for easy access.
  PropertyBag get properties => owner.properties;
  EventListenerMap get events => owner.events;
  Transform get transform => owner.transform;
  Scene get scene => owner.scene;

  Component() {
  }

  void _attach(int handle, GameObject owner) {
    this.handle = handle;
    this.owner = owner;
  }

  void _destroy() {
    handle = null;
    owner = null;
  }

  void init([List params]) {
  }

  void update() {
  }

  void free() {
  }
}
