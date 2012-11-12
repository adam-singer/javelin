part of javelin_game;

abstract class Serializable {
  String toJson();
  void fromJson(String json);
}
