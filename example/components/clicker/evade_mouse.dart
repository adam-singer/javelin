
class EvadeMouse extends ScriptComponent{

  // Components can have private properties. This data does not need to be
  // exposed to any other component, so we don't use the property bag.
  num _speed = 20;

  num _mouseX;
  num _mouseY;

  // Constructors are a terible idea for components.
  // Use init instead.
  // Parameters for init are provided as a list when you create the component.
  // Internally we use Function.apply to get this to work.
  void init([List params]) {
    // Cannot use constructor's syntax sugar because this is not a
    // constructor :(
    _speed = params[0];

    // This throws an exception if MouseEvents component is not present on the
    // Game Object.
    requireComponent('MouseEvents');

    // MouseEvents fires mouse events (duh!).
    events.on('mouseMove').add(captureMouse);

    // Just for fun, set a property in the property bag so that other
    // components can read it. In this case, DestroyOnClick will read it.
    properties.set('secretMessage', 'Hi! I am a property!');
  }

  // The signature for this callback should be specified in the
  // MouseEvents component API.
  void captureMouse([List params]) {
    _mouseX = params[0];
    _mouseY = params[1];
  }

  // This is not an event handler.
  // All components support init, update and free.
  // update gets called every frame.
  void update(num timeDelta) {
    // TODO(demo): get the projection of the mouse coordinates, stored in
    // _mouseX and _mouseY onto the ground plane using the current camera.
    // I added a property bag to the scene and I was thinking of having the
    // camera component do owner.scene.properties.set('camera', this), so that
    // we can always get the last camera added.
    vec3 mouseProjection;

    // owner is the GameObject that owns this component.
    // All game objects have a Transform component.
    // owner.transform is a shortcut for owner.getComponent('Transform')
    vec3 delta = mouseProjection - owner.transform.position;
    if(delta.length2 < 100*100) {
      delta = delta * (-1 *_speed * timeDelta);
      owner.transform.translate(delta);
    }
  }
}
