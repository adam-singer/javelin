part of javelin_state;

class SimpleCloner {

  /**
   * Takes 2 objects of any type and copies the value of the fields from the
   * first one onto the second one (for the fields with the same name).
   *
   *  - No objects are constructed. The target object must already have all
   * all the children, including collection elements, that it wants copied
   * from the source.
   *  - List and Map elements are copies 'as is'. No recursive copying is
   * applied on them.
   *  - Any field not present in the source object will be left untouched on the
   * target object.
   */
  static Future _copyFields(dynamic from, dynamic to, [List<Future> futures]) {
    InstanceMirror fromMirror = reflect(from);
    InstanceMirror toMirror = reflect(to);

    if (futures == null){
      futures = [];
    }

    for (var fieldName in toMirror.type.variables.keys) {
      var field = toMirror.type.variables[fieldName];
      if (field is VariableMirror) {
        if (fromMirror.type.variables.containsKey(fieldName)) {
          _copyField(from, to, fieldName, futures);
        }
      }
    }

    // Wait for all 3 collections of futures.
    var completer = new Completer();
    return completer.future;
  }

  static void _copyField(dynamic from,
                         dynamic to,
                         String fieldName,
                         List<Future> futures) {

    InstanceMirror fromMirror = reflect(from);
    InstanceMirror toMirror = reflect(to);

    var getFromValueFuture = fromMirror.getField(fieldName);
    futures.add(getFromValueFuture);
    getFromValueFuture.then((fromValueMirror) {

      // Simple type.
      if (fromValueMirror.reflectee is num ||
          fromValueMirror.reflectee is bool ||
          fromValueMirror.reflectee is String ||
          fromValueMirror.reflectee == null) {
        _writeField(fieldName, fromValueMirror.reflectee, toMirror,
            futures);
        return;
      }

      var getToValueFuture = toMirror.getField(fieldName);
      futures.add(getToValueFuture);
      getToValueFuture.then((toValueMirror) {

        if (fromValueMirror.reflectee is List) {
          _copyList(fromValueMirror, toValueMirror, futures);
        }
        else if (fromValueMirror.reflectee is Map) {
          _copyMap(fromValueMirror, toValueMirror, futures);
        }
        // Two objects of the same type, just apply the function recursively
        else if (fromValueMirror.reflectee.runtimeType ==
                 toValueMirror.reflectee.runtimeType) {
          _copyFields(fromValueMirror.reflectee, toValueMirror.reflectee,
              futures);
        }

      }); // getToValueFuture
    }); // getFromValueFuture

  }

  static void _copyList(InstanceMirror fromValueMirror,
                        InstanceMirror toValueMirror,
                        List<Future> futures) {
    for (var i = 0; i < fromValueMirror.reflectee.length; i++) {
      var readElementFuture =  fromValueMirror.invoke('[]', [i], null);
      futures.add(readElementFuture);
      readElementFuture.then((valueMirror) {
        var writeElementFuture = toValueMirror.invoke('[]=',
            [i, fromValueMirror.reflectee], null);
        futures.add(writeElementFuture);
      });
    }
  }

  static void _copyMap(InstanceMirror fromValueMirror,
                        InstanceMirror toValueMirror,
                        List<Future> futures) {
    for (var key in fromValueMirror.reflectee.keys) {
      var readElementFuture =  fromValueMirror.invoke('[]', [key], null);
      futures.add(readElementFuture);
      readElementFuture.then((valueMirror) {
        var writeElementFuture = toValueMirror.invoke('[]=',
            [key, fromValueMirror.reflectee], null);
        futures.add(writeElementFuture);
      });
    }
  }

  static Future<dynamic> _getFieldValueToCopy(InstanceMirror fromValueMirror,
                                              InstanceMirror toValueMirror,
                                              List<Future> futures) {
    var completer = new Completer();
    futures.add(completer.future);

    // Simple type.
    if (fromValueMirror.reflectee is num ||
        fromValueMirror.reflectee is bool ||
        fromValueMirror.reflectee is String ||
        fromValueMirror.reflectee == null) {
      completer.complete(fromValueMirror.reflectee);
    }
    else if (fromValueMirror.reflectee is List) {

    }
    else if (fromValueMirror.reflectee is Map) {

    }
    // Two objects of the same type, just apply the function recursively
    else if (fromValueMirror.reflectee.runtimeType ==
             toValueMirror.reflectee.runtimeType) {
      _copyFields(fromValueMirror.reflectee, toValueMirror.reflectee,
          futures);
    }
  }

  static void _writeField(String fieldName,
                       dynamic value,
                       InstanceMirror toMirror,
                       List<Future> futures) {
      var setValueFuture =
          toMirror.setField(fieldName, value);
      futures.add(setValueFuture);
  }
}
