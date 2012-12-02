part of javelin_render;

// Specialization of shader.
// Shader is used as basic state
// Material overrides any of those settings.
class Material {
    final Shader shader;
    Map<String, Texture> textures = new Map<String, Texture>();
    Map<String, SamplerState> samplers = new Map<String, SamplerState>();

    DepthState depthState;
    RasterizerState rasterizerState;
    BlendState blendState;

    Material(this.shader);

    void apply() {
    }
}
