
class Enemy extends GameObject{
  Enemy() {

    // All GameObjects have a Transform component by default.

    // Components.create(type, go, [params]) is a shortcut for:
    // Components.get(type).create(go, [params]) which is a shortcut for:
    // Scene.current.components.get(type).create(go, [params])

    // This component fires mouse events. It is not a ScriptComponent, its
    // part of Javelin.
    attachComponent('MouseEvents');

    // RenderableMesh is another Javelin Component to display meshes.
    // I don't know how to create a mesh in Spectre.
    dynamic enemyMesh; // TODO(demo): Get a mesh from spectre.
    attachComponent('RenderableMesh', [enemyMesh]);

    // Custom components (ScriptComponents):

    // 20 (the speed) will be passed as parameter to the init
    // function of EvadeMouse.
    attachComponent('EvadeMouse', [20]);
    attachComponent('DestroyOnClick');
  }
}
