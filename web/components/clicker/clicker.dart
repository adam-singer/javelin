library javelin_click_demo;

import 'dart:html';
import 'package:vector_math/vector_math_browser.dart';
import 'package:javelin/javelin.dart';
import 'package:javelin/javelin_game.dart';

part 'evade_mouse.dart';
part 'destroy_on_click.dart';
part 'score_printer.dart';

class Clicker extends Scene {

  GameObject _scoreManager;

  // E.g. A game is a collection of scenes (kind of provide a basic state
  // machine here, with functions like switchToScene, etc.)
  Clicker() : super(256) {

    // Create a prefab.
    var enemy= new GameObject();
    enemy.attachComponent('MouseEvents');
    dynamic enemyMesh; // TODO(demo): Get a mesh from spectre.
    //attachComponent('RenderableMesh', [enemyMesh]);
    enemy.attachComponent('EvadeMouse');
    enemy.attachComponent('DestroyOnClick');
    Prefab enemyPrefab = new Prefab.fromGameObject(enemy);

    // Add enemies to the scene by instantiating the prefab.
    for(var i = 0 ; i < 10 ; i++) {
      root.addChild(enemyPrefab.instantiate());
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
  Game.componentManager.registerComponentSystem('javelin_click_demo.ScorePrinter', scorePrinterSystem);

  var transformPool = new ComponentPool<Transform>(Transform.componentConstructor);
  var transformSystem = new ComponentSystem<Transform>(transformPool);
  Game.componentManager.registerComponentSystem('Transform', transformSystem);

  var mouseEventsPool = new ComponentPool<MouseEvents>(MouseEvents.componentConstructor);
  var mouseEventsSystem = new ComponentSystem<MouseEvents>(mouseEventsPool);
  Game.componentManager.registerComponentSystem('MouseEvents', mouseEventsSystem);
  Game.componentManager.registerComponentSystem('javelin_game.MouseEvents', mouseEventsSystem);

  var evadeMousePool = new ComponentPool<EvadeMouse>(EvadeMouse.componentConstructor);
  var evadeMouseSystem = new ComponentSystem<EvadeMouse>(evadeMousePool);
  Game.componentManager.registerComponentSystem('EvadeMouse', evadeMouseSystem);
  Game.componentManager.registerComponentSystem('javelin_click_demo.EvadeMouse', evadeMouseSystem);

  var destroyOnClickPool = new ComponentPool<DestroyOnClick>(DestroyOnClick.componentConstructor);
  var destroyOnClickSystem = new ComponentSystem<DestroyOnClick>(destroyOnClickPool);
  Game.componentManager.registerComponentSystem('DestroyOnClick', destroyOnClickSystem);
  Game.componentManager.registerComponentSystem('javelin_click_demo.DestroyOnClick', destroyOnClickSystem);
}

void main() {
  // Initialize the game
  Game.init();
  _registerComponentSystemsWithGame();

  Clicker clickerScene = new Clicker();
  print('initialized clicker');
  print(clickerScene.root.toJson());
}