part of javelin_game;

/// Fires KeyBoardEvents.

class KeyboardEvents extends Component {
  KeyboardEvents() {
    _type = 'KeyboardEvents';
  }

  static KeyboardEvents componentConstructor() {
    //TODO(johnmccutchan): Return a singleton.
    return new KeyboardEvents();
  }
}