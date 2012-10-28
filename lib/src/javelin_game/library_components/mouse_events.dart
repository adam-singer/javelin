
/// Fires MouseEvents.

class MouseEvents extends Component {
  MouseEvents() {
    _type = 'MouseEvents';
  }
  static MouseEvents componentConstructor() {
    //TODO(johnmccutchan): Return a singleton
    return new MouseEvents();
  }
}