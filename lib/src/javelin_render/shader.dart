part of javelin_render;

/*
 * FIRST STEPS:
 * Auto update uniform and attribute table.
 *
 * Allow setting uniforms setConstant(name, value) work.
 *
 * Allow setting of texture names to texture units.
 *
 * Default values for each uniform value.
 *
 * Clone a material with all default values set.
 *
 * Query for compile and link logs.
 */

//Add standard camera transform uniforms
//Add standard mesh transform uniforms
//Shader metadata:
//   Layer to render into
//   Initial values for each uniform value
//   Names of textures to use for each sampler input
//Extract from compiler shader:
//  Attribute inputs
//  Uniform inputs
//http://www.gamedev.net/topic/169710-materialshader-implmentation/

class Shader {
  List<String> layers;
  final GraphicsDevice device;
  VertexShader vertexShader;
  FragmentShader fragmentShader;
  ShaderProgram shaderProgram;
  int _version = 0;
  int frameIndex = 0;
  int get version => _version;
  bool autoBuild = true;
  String _vertexSource;
  String _fragmentSource;
  Map<String, Uniform> _uniforms;
  Map<String, Attribute> _attributes;
  Shader(this.device) {
    _uniforms = new Map<String, Uniform>();
  }

  void _refreshUniforms() {
  }

  void _refreshAttributes() {
  }

  void rebuild() {
    // Compile vertex shader
    // Compile fragment shader
    // Link program
    // Check link status
    // Refresh uniforms
    // Refresh attributes
    _version++;
  }

  String get vertexSource => _vertexSource;
  set vertexSource(String source) {
    _vertexSource = source;
    if (autoBuild)
      rebuild();
  }

  String get fragmentSource => _fragmentSource;
  set fragmentSource(String source) {
    _fragmentSource = source;
    if (autoBuild)
      rebuild();
  }
  void setConstant(String name, dynamic value) {
    Uniform uniform = _uniforms[name];
    if (uniform == null) {
      return;
    }
    uniform.apply(uniform._location, value);
  }
}
