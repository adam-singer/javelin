part of javelin_click_demo;

class EvadeMouse extends ScriptComponent {

  EvadeMouse() : super('EvadeMouse');

  static EvadeMouse componentConstructor() {
    return new EvadeMouse();
  }

  num get speed => data.speed;
  void set speed(num value) { data.speed = value; }

  num get mouseX => data.mouseX;
  void set mouseX(num value) { data.mouseX = value; }

  num get mouseY => data.mouseY;
  void set mouseY(num value) { data.mouseY = value; }

  // Constructors are a terible idea for components.
  // Use init instead.
  // Parameters for init are provided as a list when you create the component.
  // Internally we use Function.apply to get this to work.
  void init([PropertyList params]) {
    // This throws an exception if MouseEvents component is not present on the
    // Game Object.
    requireComponent('MouseEvents');

    // MouseEvents fires mouse events (duh!).
    events.on('mouseMove').add(captureMouse);

    // Just for fun, set a property in the property bag so that other
    // components can read it. In this case, DestroyOnClick will read it.
    owner.data.secretMessage = 'Hi! I am a property!';
  }

  // The signature for this callback should be specified in the
  // MouseEvents component API.
  void captureMouse([List params]) {
    mouseX = params[0];
    mouseY = params[1];
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
      delta = delta * (-1 * speed * timeDelta);
      owner.transform.translate(delta);
    }
  }
}
