
class DestroyOnClick extends ScriptComponent{

  void init([List params]) {
    require('MouseEvents');
    events.on('click').add(destroy);
  }

  void destroy(num mouseX, num mouseY) {

    // Before we die, let's read a property set by EvadeMouse, just for fun:
    var message = properties.get('secretMessage');
    if(message != null)
      print(message);

    // Fire an event on the scene's root to notify the ScoreManager.
    // In practice you could just get a reference to the object you want
    // and fire an event on it rather than broadcast to the whole scene.
    scene.root.events.broadcast('enemyDestroyed');

    // Spawn an explosion object.
    // I am doing it all in place to demonstrate that is possible but
    // you may want to have an Explosion class instead.
    GameObject explosion = new GameObject();

    // Remember that owner is the game object that owns this component.
    explosion.transform.position = owner.transform.position.clone();
    owner.addChild(explosion);

    Mesh mesh = createAMeshInSpectre(magic);
    Components.create('AnimatedMesh', explosion, [mesh]);

    // Tracker provides time management operations.
    // Tell the scene's tracker to kill us when the animation is done.
    scene.tracker.callFunctionWithDelay(mesh.animation.duration, () {
      // This will also destroy all other components this game object has, and
      // recursively destroy all childen as well, including the explosion.
      scene.destroyGameObject(owner);
    });
  }

}
