part of javelin_game;

class PropertyMap implements Map<String, dynamic>, Serializable {

  Map<String, dynamic> _objectData;

  // Implementation of Map<String, dynamic>
  bool containsValue(dynamic value) => _objectData.containsValue(value);
  bool containsKey(String key) => _objectData.containsKey(key);
  operator [](String key) => _objectData[key];
  forEach(func(String key, dynamic value)) => _objectData.forEach(func);
  Collection<String> get keys => _objectData.keys;
  Collection<dynamic> get values => _objectData.values;
  int get length => _objectData.length;
  bool get isEmpty => _objectData.isEmpty;
  operator []=(String key, dynamic value) => _objectData[key] = value;
  putIfAbsent(String key,ifAbsent()) =>_objectData.putIfAbsent(key, ifAbsent);
  clear() => _objectData.clear();
  remove(String key) => _objectData.remove(key);

  /**
   * Implementing noSuchMethod allows invocations on this object in a more
   * natural way:
   *  - print(data.propertyName);
   *  - data.propertyName = value;
   * instead of:
   *  - print(data.get('propertyName'));
   *  - data.set('propertyName', value);
   */
  noSuchMethod(InvocationMirror mirror) {
    if (mirror.memberName.startsWith("get:")) {
      var property = mirror.memberName.replaceFirst("get:", "");
      if (this.containsKey(property)) {
        return this[property];
      }
    }
    else if (mirror.memberName.startsWith("set:")) {
      var property = mirror.memberName.replaceFirst("set:", "");
      this[property] = mirror.positionalArguments[0];
      return this[property];
    }

    //if we get here, then we've not found it - throw.
    print("Not found: ${mirror.memberName}");
    print("IsGetter: ${mirror.isGetter}");
    print("IsSetter: ${mirror.isGetter}");
    print("isAccessor: ${mirror.isAccessor}");
    super.noSuchMethod(mirror);
  }

  String toJson() {
  }

  void fromJson(String json) {
  }

}
