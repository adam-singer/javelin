library javelin_game_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import '../../lib/javelin_game.dart';

part './mock_component.dart';

void main() {

  useHtmlEnhancedConfiguration();

  group('Scene Tests: ', () {

    Scene scene;

    setUp(() {
      Game.init();
      scene = new Scene(100);
      var pool =
          new ComponentPool<MockComponent>(MockComponent.componentConstructor);
      var system = new ComponentSystem<MockComponent>(pool);
      Game.componentManager.registerComponentSystem('MockComponent', system);
    });

    test('Root exists', () {
      expect(scene.root, isNotNull);
      expect(scene.root, new isInstanceOf<GameObject>());
    });

    test('Register game object', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      expect(go.scene, scene);
      expect(go.parent, scene.root);
      expect(scene.root.children, orderedEquals([go]));
    });

    test('Register game object with a duplicate id', () {
      var go1 = new GameObject('duplicate_id');
      scene.root.addChild(go1);
      var go2 = new GameObject('duplicate_id');
      try {
        //We expect an exception on this line.
        scene.root.addChild(go2);
        expect(false, null, reason: 'Unreachable.');
      }
      catch (e) {
        expect(e, isNotNull);
      }
    });

    test('Destroy game object', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      scene.destroyGameObject(go);
      expect(scene.root.children, isEmpty);
    });

    test('Get game object with id', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      var found = scene.getGameObjectWithId('game_object_id');
      expect(go, found);
    });

    test('Register a tree of game objects', () {
      var parent = new GameObject('parent');
      var child1 = parent.addChild(new GameObject('child1'));
      var child2 = parent.addChild(new GameObject('child2'));
      scene.root.addChild(parent);

      var foundParent = scene.getGameObjectWithId('parent');
      var foundChild1 = scene.getGameObjectWithId('child1');
      var foundChild2 = scene.getGameObjectWithId('child2');
      expect(parent, foundParent);
      expect(child1, foundChild1);
      expect(child2, foundChild2);
      expect(scene.root.children, orderedEquals([parent]));
      expect(parent.children, unorderedEquals([child1, child2]));
      expect(child1.parent, parent);
      expect(child1.scene, scene);
    });

    test('Destroy the root of a tree of game objects', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      var child1 = new GameObject('child1');
      go.addChild(child1);
      var child2 = new GameObject('child2');
      go.addChild(child2);
      scene.destroyGameObject(go);

      expect(scene.root.children, isEmpty);
      expect(go.scene, isNull);
      expect(go.parent, isNull);
      expect(child1.scene, isNull);
      expect(child1.parent, isNull);
      expect(child2.scene, isNull);
      expect(child2.parent, isNull);
    });
  });

  group('GameObject Tests: ', () {

    Scene scene;

    setUp(() {
      Game.init();
      scene = new Scene(100);

      var pool1 =
          new ComponentPool<MockComponent>(MockComponent.componentConstructor);
      var system1 = new ComponentSystem<MockComponent>(pool1);
      Game.componentManager.registerComponentSystem('MockComponent', system1);

      var pool2 =
          new ComponentPool<MockDependencyComponent>(
            MockDependencyComponent.componentConstructor);
      var system2 = new ComponentSystem<MockDependencyComponent>(pool2);
      Game.componentManager.registerComponentSystem('MockDependencyComponent',
          system2);
    });

    test('Add a child', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      var child = new GameObject('child');
      go.addChild(child);
      scene.root.addChild(go);

      expect(child.scene, go.scene);
      expect(child.parent, go);
      expect(go.children, orderedEquals([child]));
    });

    test('Destroy a child', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      var child = new GameObject('child');
      go.addChild(child);
      var c = child.attachComponent('MockComponent');
      scene.destroyGameObject(child);

      expect(child.scene, isNull);
      expect(child.parent, isNull);
      expect(go.children, isEmpty);
      expect(c.owner, isNull);
    });

    test('Attach component', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      var c = go.attachComponent('MockComponent');
      expect(c, isNotNull);
      expect(c, new isInstanceOf<MockComponent>());
      expect(c.owner, go);
    });

    test('Attach multiple components', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      var c1 = go.attachComponent('MockComponent');
      var c2 = go.attachComponent('MockDependencyComponent');
      expect(c1, isNot(equals(c2)));
    });

    test('Get a component', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      var c = go.attachComponent('MockComponent');
      go.attachComponent('MockDependencyComponent');
      var found = go.getComponent('MockComponent');
      expect(c, found);
    });

    test('Get all components of type', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      var c1 = go.attachComponent('MockComponent');
      var c2 = go.attachComponent('MockComponent');
      var c3 = go.attachComponent('MockDependencyComponent');
      var c4 = go.attachComponent('MockComponent');
      var found = go.getComponents('MockComponent');
      expect(found, unorderedEquals([c1, c2, c4]));
    });

    test('Get all components of type when none were attached', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      var found = go.getComponents('MockComponent');
      expect(found, isEmpty);
    });

    test('Destroy a component', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      var c1 = go.attachComponent('MockComponent');
      var c2 = go.attachComponent('MockComponent');
      var c3 = go.attachComponent('MockComponent');
      go.destroyComponent(c2);
      var found = go.getComponents('MockComponent');
      expect(found, unorderedEquals([c1, c3]));
    });

    test('Destroy a component not owned by the game object', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      var mine = go.attachComponent('MockComponent');
      var another = new GameObject();
      var notMine = another.attachComponent('MockComponent');
      try {
        //We expect an exception on this line.
        go.destroyComponent(notMine);
        expect(false, null, reason: 'Unreachable.');
      }
      catch (e) {
        expect(e, isNotNull);
      }
    });

    test('Check component dependencies', () {
      var go = new GameObject('game_object_id');
      scene.root.addChild(go);
      var c1 = go.attachComponent('MockComponent');
      var c2 = go.attachComponent('MockDependencyComponent');

      // Since c2 requires c1, destroying c2 will raise an exception.
      try {
        //We expect an exception on this line.
        go.destroyComponent(c1);
        expect(false, null, reason: 'Unreachable.');
      }
      catch (e) {
        expect(e, isNotNull);
      }
    });
  });
}
