part of javelin_game;

/**
 * Wrapper around a Map<String, dynamic>.
 */
class PropertyMap extends PropertyContainer implements Map<String, dynamic> {

  // The actual map that holds the elements.
  Map<String, dynamic> _objectData;

  /// Default constructor.
  PropertyMap() {
    _objectData = new Map<String, dynamic>();
  }

  /// Contructor from Map.
  PropertyMap.from(Map<String, dynamic> other) {
    _objectData = new Map.from(other);
    for (var key in _objectData.keys) {
      assert(key is String);
      _objectData[key] = _validate(_objectData[key]);
    }
  }

  // Implementation of Map<String, dynamic>
  bool containsValue(dynamic value) => _objectData.containsValue(value);
  bool containsKey(String key) => _objectData.containsKey(key);
  forEach(func(String key, dynamic value)) => _objectData.forEach(func);
  Collection<String> get keys => _objectData.keys;
  Collection<dynamic> get values => _objectData.values;
  int get length => _objectData.length;
  bool get isEmpty => _objectData.isEmpty;
  putIfAbsent(String key,ifAbsent()) {
    _objectData.putIfAbsent(key, () {
      _validate(ifAbsent());
    });
  }
  clear() => _objectData.clear();
  remove(String key) => _objectData.remove(key);
  operator [](String key) => _objectData[key];
  operator []=(String key, dynamic value) {
    _objectData[key] = _validate(value);
  }

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

  /**
   * Serialize.
   */
  String toJson() {
    var buffer = new StringBuffer();
    buffer.add('{');
    var first = true;
    for (var key in _objectData.keys) {
      first ? first = false : buffer.add(',');
      buffer.add('"${key}":');
      var value = _objectData[key];
      if (value is num || value is bool) {
        buffer.add(value);
      }
      else if (value is String) {
        buffer.add('"${value}"');
      }
      else if (value is Serializable) {
        buffer.add(value.toJson());
      }
      else {
        var mirror = reflect(value);
        throw 'Unexpected value found on a PropertyMap. Type found: '
        '${mirror.type.simpleName}.';
      }
    }
    buffer.add('}');
    return buffer.toString();
  }

  /**
   * Deserialize.
   */
  void fromJson(dynamic json) {
    assert(json is Map);
    _objectData = new Map.from(json);
    for (var key in _objectData.keys) {
      assert(key is String);
      _objectData[key] = _validate(_objectData[key]);
    }
  }

  String toString() {
    return 'PropertyMap:${_objectData.toString()}';
  }
}
