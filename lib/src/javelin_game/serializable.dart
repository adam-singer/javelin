part of javelin_game;

abstract class Serializable {
  String toJson();
  void fromJson(dynamic json);
}
