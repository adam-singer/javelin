
#library("javelin_clicker_demo");

#import('../../../lib/Javelin.dart');
#import('../../../lib/javelin_scene.dart');

#source('enemy.dart');
#source('evade_mouse.dart');
#source('destroy_on_click.dart');
#source('score_printer.dart');

class Clicker extends Scene{

  GameObject _scoreManager;

  // Suggestion: Move the code that deals with the device and resource
  // management out of the scene and into a Game or Application class so that
  // you don't have to pass these around for every scene.
  // E.g. A game is a collection of scenes (kind of provide a basic state
  // machine here, with functions like switchToScene, etc.)
  Clicker(Device device, ResourceManager resourceManager):
          super(device, resourceManager) {

    // Add 100 enemies to the scene. Enemy extends GameObject.
    for(var i = 0 ; i < 100 ; i++) {
      // root is the root of the scene graph.
      // The constructor of Enemy will add the components it needs.
      root.addChild(new Enemy());
    }

    // Also add a vanilla GameObject and manually add a component to it:
    _scoreManager = new GameObect();
    components.create('ScorePrinter', _scoreManager);
    root.addChild(_scoreManager);
  }
}
