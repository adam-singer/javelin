
class PropertyBag {
  Map<String, Dynamic> _properties;
  PropertyBag() {
    _properties = new Map<String, Dynamic>();
  }

  void set(String name, Dynamic value) {
    _properties[name] = value;
  }

  Dynamic get(String name) {
    return _properties[name];
  }

  void clear() {
    _properties.clear();
  }
}