part of javelin_click_demo;

class ScorePrinter extends ScriptComponent {

  int _score = 0;

  ScorePrinter() : super('ScorePrinter');

  static ScorePrinter componentConstructor() {
    return new ScorePrinter();
  }

  void init([List params]) {
    events.on('enemyDestroyed').add(onEnemyDestroyed);
  }

  void onEnemyDestroyed([List params]) {
    _score += 10;
    print(_score);
  }
}
