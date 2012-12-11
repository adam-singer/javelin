part of javelin_render;

/**
 * The drawable class contains everything needed to draw an instance of a mesh:
 *  Mesh
 *  Material
 *
 */
class Drawable {
  Mesh _mesh;
  Material _material;
  InputLayout _inputLayout;
  // Bounding Box.

  Drawable({Mesh mesh, Material material}) {
    _mesh = mesh;
    _material = material;
    _link();
  }

  Mesh get mesh => _mesh;
  set mesh(Mesh m) {
    _mesh = m;
    _link();
  }

  Material get material => _material;
  set material(Material m) {
    _material = m;
    _link();
  }

  void _link() {

  }

  void _draw() {
    // Apply mesh
    // Apply material
    // Draw
  }
}
