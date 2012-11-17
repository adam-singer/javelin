part of javelin_game;

/**
 * Provides a way of using html elements as GameObjects.
 * Will update the element's CSS transformation every frame, according to the
 * 3d transform of the game object that owns this component.
 * Parenting is not supported.
 */
class HtmlElement extends Component {
  String _htmlId;
  Element _element;

  HtmlElement() {
    _type = 'HtmlElement';
  }

  static HtmlElement componentConstructor() {
    return new HtmlElement();
  }

  /// First element of the list is the element's id on the page.
  void init([PropertyList params]) {
    _htmlId = params[0];
    _element = query(_htmlId);
  }

  void update(num timeDelta) {
    vec3 p = transform.position;
    _element.style.transform = "translate(${p.x}px, ${p.y}px)";
  }
}
