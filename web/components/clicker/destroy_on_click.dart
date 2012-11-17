part of javelin_click_demo;

class DestroyOnClick extends ScriptComponent {

  DestroyOnClick() : super('DestroyOnClick');

  static DestroyOnClick componentConstructor() {
    return new DestroyOnClick();
  }

  void init([PropertyList params]) {
    requireComponent('MouseEvents');
    events.on('click').add(destroy);
  }

  void destroy([List params]) {

    // Before we die, let's read a property set by EvadeMouse, just for fun:
    var message = owner.data.secretMessage;
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
    explosion.transform.position = owner.transform.position.xyz; // clone
    owner.addChild(explosion);

    dynamic mesh; //TODO (demo): Get a mesh from spectre.
    explosion.attachComponent('AnimatedMesh', [mesh]);

    // Tell the scene's tracker to kill us when the animation is done.
    //TODO(johnmccutchan): Add a timer class to the scene.
    window.setTimeout(() {
      // This will also destroy all other components this game object has, and
      // recursively destroy all childen as well, including the explosion.
      scene.destroyGameObject(owner);
    }, mesh.animation.duration);
  }
}
