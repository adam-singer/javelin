part of javelin_game;

/**
 * Implements a property bag capable of holding values in the form of a map of
 * key value pairs. The values are restricted to numbers, booleans, strings,
 * objects that implement Seriablizable and Lists, Maps and Sets that hold these
 * kinds of objects.
 *
 * Because a property bag is Serializable it is a valid property value for
 * another property bag.
 */
class PropertyBag {
  Map<String, dynamic> _properties;

  /**
    * Constructor.
    */
  PropertyBag(){
    _properties = new Map<String, dynamic>();
  }

  /**
   * Sets a property for this property bag.
   */
  void set(String name, dynamic value) {
    if (_checkType(value)) {
      _properties[name] = value;
    }
  }

  /**
   * Gets the value of a property on this property bag.
   */
  dynamic get(String name) {
    return _properties[name];
  }

  /**
   * Clears all the values
   */
  void clear() {
    _properties.clear();
  }

  String serialize() {
    var buffer = new StringBuffer();
    buffer.add('{');
    var first = true;
    for(String key in _properties.keys) {
      first ? first = false : buffer.add(',');
      var value = _properties[key];
      buffer.add('"${key}":');


    }
  }

  String _serializeValue(dynamic value) {
    var buffer = new StringBuffer();
    if (value is num ||
        value is bool) {
      buffer.add(value);
    }
    else if (value is String) {
      buffer.add('"${value}"');
    }
    else if (value is Serializable) {
      buffer.add(value.serialize());
    }
    else if (value is List) {
      buffer.add('[');
      for(var i = 0; i < value.length; i++) {

      }
      buffer.add(']');
    }
  }

  deserialize(String data) {

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
  dynamic noSuchMethod(InvocationMirror mirror) {
    if (mirror.isGetter) {
      return get(mirror.positionalArguments[0]);
    }
    if (mirror.isSetter) {
      set(mirror.positionalArguments[0], mirror.positionalArguments[1]);
    }

    return null;
  }

  /**
   * Returns true if the provided value is a valid value for a property bag,
   * otherwise throws an exception.
   */
  bool _checkType(dynamic value) {
    if (value is num ||
        value is bool ||
        value is String ||
        value == null ||
        value is Serializable) {
      return true;
    }
    else if (value is List ||
             value is Map ||
             value is Set) {
      var ok = true;
      value.forEach((element) => ok = ok && _checkType(element));
      return ok;
    }

    var mirror = reflect(value);
    throw 'Value not supported on a PropertyBag. Trying to save an instance '
    'of ${mirror.type.simpleName}. Only numbers, booleans, Strings, '
    'classes that implement Serializable and Lists, Maps and Sets of those'
    'types are allowed as values on a PropertyBag.';
    return false;
  }
}