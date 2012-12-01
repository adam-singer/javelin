part of javelin_render;

typedef void ApplyUniformMethod(dynamic location, dynamic value);

class Uniform {
  final String name;
  final String type;
  final dynamic defaultValue;
  final dynamic _location;
  final ApplyUniformMethod apply;
  Uniform(this.name, this.type, this.defaultValue, this._location, this.apply);
}