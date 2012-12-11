part of javelin_game;

/// Wrapper around a Specre transform.
class Transform extends Component {
  mat4 _localTransform;
  mat4 _worldTransform;
  bool _overrideParentTransform;

  Transform() {
    _type = 'Transform';
    _localTransform = new mat4.identity();
    _worldTransform = new mat4.identity();
    _overrideParentTransform = false;
  }

  static Transform componentConstructor() {
    return new Transform();
  }

  /** Translates this transform by [delta]
   */
  void translate(vec3 delta) {
    _localTransform.translate(delta);
  }

  /**
   * Change the translation
   */
  set position(vec3 x) {
    _localTransform.setTranslation(x);
  }

  /**
   * Get the translation
   */
  vec3 get position {
    return _localTransform.col3.xyz;
  }

  //TODO(johnmccutchan): Add support for accessing world matrix
  void copyWorldTransformUniform(Float32Array buff, [int offset=0]) {
    _worldTransform.copyIntoArray(buff, offset);
  }

  void updateWorldTransform(mat4 parent) {
    if (_overrideParentTransform) {
      // Local transform is the world transform
      _worldTransform.copyFrom(_localTransform);
    } else {
      _worldTransform = parent * _localTransform;
    }
  }
}