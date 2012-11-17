part of javelin_click_demo;

class ScorePrinter extends ScriptComponent {

  int get score => data.score;
  void set score(int value) { data.score = value; }

  ScorePrinter() : super('ScorePrinter');

  static ScorePrinter componentConstructor() {
    return new ScorePrinter();
  }

  void init([PropertyList params]) {
    events.on('enemyDestroyed').add(onEnemyDestroyed);
  }

  void onEnemyDestroyed([List params]) {
    score += 10;
    print(score);
  }
}
