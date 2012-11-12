part of javelin_game;

abstract class PropertyContainer implements Serializable {

  /**
   * Returns the passed value if the provided value is a an acceptable entry for
   * a PropertyContainer. If the value is a Map or a List, it will be converted
   * into a PropertyMap or a PropertyList (recursively), otherwise it throws an
   * exception.
   */
  dynamic _validate(dynamic value) {
    if (value is num ||
        value is bool ||
        value is String ||
        value == null ||
        value is Serializable) {
      return value;
    }
    else if (value is List) {
      return new PropertyList.from(value);
    }
    else if (value is Map) {
      return new PropertyMap.from(value);
    }

    var mirror = reflect(value);
    throw 'Value not supported on a PropertyContainer. Trying to save an '
    'instance of ${mirror.type.simpleName}. Only numbers, booleans, Strings, '
    'classes that implement Serializable and Lists and Maps of those'
    'types are allowed as values on a PropertyContainer.';
    return null;
  }
}
