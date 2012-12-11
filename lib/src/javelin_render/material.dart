part of javelin_render;

/** A material is a configuration applied to a shader.
 * The shader defines the basic functionality and the material defines
 * the inputs to the shader
 */
class Material {
    final Renderer renderer;
    final Shader shader;
    // A mapping from uniform name to uniform value.
    final Map<String, dynamic> uniforms = new Map<String, dynamic>();
    // A mapping from sampler name to texture name.
    final Map<String, String> textures = new Map<String, String>();

    DepthState _depthState;
    DepthState get depthState => _depthState;
    RasterizerState _rasterizerState;
    RasterizerState get rasterizerState => _rasterizerState;
    BlendState _blendState;
    BlendState get blendState => _blendState;

    Material(this.renderer, this.shader) {
    }

    /** Clone the material and return the clone. */
    Material clone() {
      Material clone = new Material(renderer, shader);
    }

    /** Apply this material to be used for rendering */
    void apply(GraphicsDevice device) {
      device.context.setBlendState(_blendState);
      device.context.setRasterizerState(_rasterizerState);
      device.context.setDepthState(_depthState);
    }
}
