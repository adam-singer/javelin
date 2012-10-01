
class ScorePrinter extends ScriptComponent{

  int _score = 0;

  void init() {
    // Suscribing to a custom event, fired by DestroyOnClick.
    events.on('enemyDestroyed').add(onEnemyDestroyed);
  }

  void onEnemyDestroyed() {
    _score += 10;
    print(_score);
  }
}
