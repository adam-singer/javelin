part of javelin_render;

/*
 * FIRST STEPS:
 *
 * Allow setting uniforms setConstant(name, value) work.
 * Allow setting of texture names to texture units.
 *
 * Default values for each uniform value.
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
  final GraphicsDevice device;
  final String name;
  VertexShader _vertexShader;
  FragmentShader _fragmentShader;
  ShaderProgram _shaderProgram;
  List<String> layers;
  int get version => _version;
  int _version = 0;
  int frameIndex = 0;
  bool autoBuild = true;

  Shader(this.name, this.device) {
    _vertexShader = device.createVertexShader('$name[VS]', {});
    _fragmentShader = device.createFragmentShader('$name[FS]', {});
    _shaderProgram = device.createShaderProgram('$name[SP]', {});
    _shaderProgram.attach(_vertexShader);
    _shaderProgram.attach(_fragmentShader);
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

  String get vertexSource => _vertexShader.source;
  set vertexSource(String source) {
    _vertexShader.source = source;
    if (autoBuild)
      rebuild();
  }

  String get fragmentSource => _fragmentShader.source;
  set fragmentSource(String source) {
    _fragmentShader.source = source;
    if (autoBuild)
      rebuild();
  }

  void setConstant(String name, dynamic value) {
    ShaderProgramUniform uniform = _shaderProgram.uniforms[]
    Uniform uniform = _uniforms[name];
    if (uniform == null) {
      return;
    }
    uniform.apply(uniform._location, value);
  }
}
