
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

  void fire([List params]) {
    _listeners.forEach((l) {
      l(params);
    });
  }
}

class EventListenerMap {
  Map<String, EventListenerSet> _events;

  EventListenerMap() {
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
    listeners.fire(params);
  }
}
