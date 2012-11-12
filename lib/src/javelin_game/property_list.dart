part of javelin_game;

class PropertyList implements List<dynamic>, Serializable {

  List _objectData;

  // Implementation of List

  forEach(func(dynamic value)) => _objectData.forEach(func);
  int get length => _objectData.length;
  bool get isEmpty => _objectData.isEmpty;
  operator [](int index) => _objectData[index];
  operator []=(int index, dynamic value) => _objectData[index] = value;
  clear() => _objectData.clear();
  Collection map(f(element)) => _objectData.map(f);
  Collection filter(bool f(element)) => _objectData.filter(f);
  bool every(bool f(element)) => _objectData.every(f);
  bool some(bool f(element)) => _objectData.some(f);
  reduce(initialValue, combine(prevValue, element)) =>
      _objectData.reduce(initialValue, combine);
  bool contains(dynamic element) => _objectData.contains(element);
  Iterator iterator() => _objectData.iterator();
  void set length(int value) { _objectData.length = value; }
  dynamic get last => _objectData.last;
  void add(dynamic value) => _objectData.add(value);
  void addLast(dynamic value) => _objectData.addLast(value);
  void addAll(Collection<dynamic> collection) => _objectData.addAll(collection);
  void sort([Comparator compare = Comparable.compare]) =>
      _objectData.sort(compare);
  int indexOf(dynamic element, [int start = 0]) =>
      _objectData.indexOf(element, start);
  int lastIndexOf(dynamic element, [int start = 0]) =>
      _objectData.lastIndexOf(element, start);
  dynamic removeAt(int index) => _objectData.removeAt(index);
  dynamic removeLast() => _objectData.removeLast();
  List<dynamic> getRange(int start, int length) =>
      _objectData.getRange(start, length);
  void setRange(int start, int length, List<dynamic> from, [int startFrom]) =>
      _objectData.setRange(start, length, from, startFrom);
  void removeRange(int start, int length) =>
      _objectData.removeRange(start, length);
  void insertRange(int start, int length, [dynamic initialValue]) =>
      _objectData.insertRange(start, length, initialValue);

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
