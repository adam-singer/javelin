
class PropertyBag {
  Map<String, dynamic> _properties;
  PropertyBag() {
    _properties = new Map<String, dynamic>();
  }

  void set(String name, dynamic value) {
    _properties[name] = value;
  }

  dynamic get(String name) {
    return _properties[name];
  }

  void clear() {
    _properties.clear();
  }
}