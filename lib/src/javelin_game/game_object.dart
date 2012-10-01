class GameObjectComponents {
  Map<String, List<int>> _components;

  GameObjectComponents() {
    _components = new Map<String, List<int>>();
  }

  void attachComponent(String componentSystemName, int handle) {
    List<int> components = _components[componentSystemName];
    if (components == null) {
      components = new List<int>();
      _components[componentSystemName] = components;
    }
    components.add(handle);
  }

  void detachComponent(String componentSystemName, int handle) {
    List<int> components = _components[componentSystemName];
    if (components == null) {
      // XXX: Throw an error or something
      return;
    }
    int index = components.indexOf(handle, 0);
    if (index == -1) {
      // XXX: Throw an error or something
      return;
    }
    components.removeAt(index);
  }
}

class GameObject {
  GameObject parent;
  Set<GameObject> children;
  PropertyBag properties;
  GameObjectComponents components;
  EventListenerMap events;

  GameObject() {
    parent = null;
    children = new Set<GameObject>();
    properties = new GameObjectProperties();
    components = new GameObjectComponents();
    events = new EventListenerMap();
  }

  EventListenerSet on(String eventName) {
    return events.on(eventName);
  }

  void fire(String eventName, [List params=null]) {
    events.fire(eventName, params);
  }

  void broadcast(String eventName, [List params=null]) {
    children.forEach((go) {
      go.fire(eventName, params);
      go.broadcast(eventName, params);
    });
  }
}
