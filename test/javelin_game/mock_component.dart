class MockComponent extends ScriptComponent {
  static MockComponent componentConstructor() {
    return new MockComponent();
  }
  MockComponent(): super('MockComponent') {
  }
}

class MockDependencyComponent extends ScriptComponent {

  static MockDependencyComponent componentConstructor() {
    return new MockDependencyComponent();
  }

  MockDependencyComponent(): super('MockDependencyComponent') {
    requireComponent('MockComponent');
  }

}
