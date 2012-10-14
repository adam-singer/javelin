/// Wrapper around a Specre transform.
class Transform extends Component {
  vec3 position = new vec3.zero();

  void translate(vec3 delta) {
    position.xyz = delta.xyz;
  }
}