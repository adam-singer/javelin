
typedef void EventListener([List params]);

class EventListenerSet {
  Set<EventListener> _listeners;
  EventListenerSet() {
    _listeners = new Set<EventListener>();
  }

  void add(EventListener listener) {
    _listeners.add(listener);
  }

  void remove(EventListener listener) {
    _listeners.remove(listener);
  }

  void _receive([List params]) {
    _listeners.forEach((l) {
      l(params);
    });
  }
}

class EventListenerMap {
  GameObject _owner;
  Map<String, EventListenerSet> _events;

  EventListenerMap(this._owner) {
    _events = new Map<String, EventListenerSet>();
  }

  EventListenerSet on(String eventName) {
    EventListenerSet listeners = _events[eventName];
    if (listeners == null) {
      listeners = new EventListenerSet();
      _events[eventName] = listeners;
    }
    return listeners;
  }

  void fire(String eventName, [List params=null]) {
    EventListenerSet listeners = _events[eventName];
    if (listeners == null) {
      return;
    }
    listeners._receive(params);
  }

  void broadcast(String eventName, [List params=null]) {
    fire(eventName, params);
    _owner.children.forEach((go) {
      go.events.broadcast(eventName, params);
    });
  }
}
