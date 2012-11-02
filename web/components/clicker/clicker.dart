library javelin_click_demo;

import 'dart:html';
import 'package:vector_math/vector_math_browser.dart';
import 'package:javelin/javelin.dart';
import 'package:javelin/javelin_game.dart';

part 'enemy.dart';
part 'evade_mouse.dart';
part 'destroy_on_click.dart';
part 'score_printer.dart';

class Clicker extends Scene {

  GameObject _scoreManager;

  // E.g. A game is a collection of scenes (kind of provide a basic state
  // machine here, with functions like switchToScene, etc.)
  Clicker() : super(256) {

    // Add 100 enemies to the scene. Enemy extends GameObject.
    for(var i = 0 ; i < 100 ; i++) {
      // root is the root of the scene graph.
      // The constructor of Enemy will add the components it needs.
      root.addChild(new Enemy());
    }

    // Also add a vanilla GameObject and manually add a component to it:
    _scoreManager = new GameObject('scoreManager');
    _scoreManager.attachComponent('ScorePrinter');
    root.addChild(_scoreManager);
  }
}

void _registerComponentSystemsWithGame() {
  // Register our component systems (manually for now).
  //TODO(johnmccutchan): Hook up dart:mirrors and find all Component classes.

  var scorePrinterPool = new ComponentPool<ScorePrinter>(ScorePrinter.componentConstructor);
  var scorePrinterSystem = new ComponentSystem<ScorePrinter>(scorePrinterPool);
  Game.componentManager.registerComponentSystem('ScorePrinter', scorePrinterSystem);

  var transformPool = new ComponentPool<Transform>(Transform.componentConstructor);
  var transformSystem = new ComponentSystem<Transform>(transformPool);
  Game.componentManager.registerComponentSystem('Transform', transformSystem);

  var mouseEventsPool = new ComponentPool<MouseEvents>(MouseEvents.componentConstructor);
  var mouseEventsSystem = new ComponentSystem<MouseEvents>(mouseEventsPool);
  Game.componentManager.registerComponentSystem('MouseEvents', mouseEventsSystem);

  var evadeMousePool = new ComponentPool<EvadeMouse>(EvadeMouse.componentConstructor);
  var evadeMouseSystem = new ComponentSystem<EvadeMouse>(evadeMousePool);
  Game.componentManager.registerComponentSystem('EvadeMouse', evadeMouseSystem);

  var destroyOnClickPool = new ComponentPool<DestroyOnClick>(DestroyOnClick.componentConstructor);
  var destroyOnClickSystem = new ComponentSystem<DestroyOnClick>(destroyOnClickPool);
  Game.componentManager.registerComponentSystem('DestroyOnClick', destroyOnClickSystem);
}

void main() {
  // Initialize the game
  Game.init();
  _registerComponentSystemsWithGame();

  Clicker clickerScene = new Clicker();
  print('initialized clicker');
  //clickerScene.getGameObjectWithId('scoreManager');
}