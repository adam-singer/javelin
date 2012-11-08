part of javelin_game;

/// Wrapper around a Specre transform.
class Transform extends Component {
  TransformGraph graph;
  int node;

  Transform() {
    _type = 'Transform';
  }

  static Transform componentConstructor() {
    return new Transform();
  }

  /** Translates this transform by [delta]
   */
  void translate(vec3 delta) {
    graph.refLocalMatrix(node).translate(delta);
  }

  /**
   * Change the translation
   */
  set position(vec3 x) {
    graph.refLocalMatrix(node).setTranslation(x);
  }

  /**
   * Get the translation
   */
  vec3 get position {
    //TODO(sethilgard): Do we want world position?
    // No. We should have local positions and add a utility method to
    // calculate the global position. Same applies to rotation an scale.
    graph.refLocalMatrix(node).col3.xyz;
  }

  /**
   * Returns a reference to the Float32Array of the final
   * world space transformation.
   */
  Float32Array get wolrdTransformUniform {
    graph.refWorldMatrixArray(node);
  }
}