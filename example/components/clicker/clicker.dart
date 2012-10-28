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
  Clicker() {

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

void main() {
  Clicker clickerGame = new Clicker();
  clickerGame.getGameObjectWithId('scoreManager');
}