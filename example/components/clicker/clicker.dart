
#library("javelin_clicker_demo");

#import('package:dartvectormath/vector_math_html.dart');
#import('../../../lib/Javelin.dart');
#import('../../../lib/javelin_game.dart');

#source('enemy.dart');
#source('evade_mouse.dart');
#source('destroy_on_click.dart');
#source('score_printer.dart');

class Clicker extends Scene{

  GameObject _scoreManager;

  // E.g. A game is a collection of scenes (kind of provide a basic state
  // machine here, with functions like switchToScene, etc.)
  Clicker() {

    // Add 100 enemies to the scene. Enemy extends GameObject.
    for(var i = 0 ; i < 100 ; i++) {
      // root is the root of the scene graph.
      // The constructor of Enemy will add the components it needs.
      root.addChild(new Enemy());
    }

    // Also add a vanilla GameObject and manually add a component to it:
    _scoreManager = new GameObject();
    _scoreManager.attachComponent('ScorePrinter');
    root.addChild(_scoreManager);
  }
}
