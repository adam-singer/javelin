part of javelin_render;

class Renderer {
  final GraphicsDevice device;
  final CanvasElement frontBuffer;
  final Map<String, Mesh> meshes = new Map<String, Mesh>();
  final Map<String, Shader> shaders = new Map<String, Shader>();
  final Map<String, Material> materials = new Map<String, Material>();
  final Map<String, Texture> textures = new Map<String, Texture>();

  Viewport frontBufferViewport;
  GlobalResources globalResources;
  LayerConfig layerConfig;
  SamplerState _npotSampler;

  void applyCameraUniforms() {
    // Walk over shaders
  }

  List<Drawable> _determineVisibleSet(List<Drawable> drawables, Camera camera) {
    List<Drawable> visibleSet = new List<Drawable>();
    int numDrawables = drawables.length;
    for (int i = 0; i < numDrawables; i++) {
      Drawable drawable = drawables[i];
      bool visible = true; // drawable.visibleTo(camera);
      if (!visible)
        continue;
      visibleSet.add(drawable);
    }
    return visibleSet;
  }

  void _sortDrawables(List<Drawable> visibleSet, int sortMode) {
  }

  void _renderPassLayer(Layer layer, List<Drawable> drawables, Camera camera,
                        Viewport viewport) {
    drawables.forEach((drawable) {
      // Apply material settings
      // Bind mesh
      // Draw
    });
  }

  void _renderFullscreenLayer(Layer layer, List<Drawable> drawables,
                              Camera camera, Viewport viewport) {
    String process = layer.properties['process'];
    String source = layer.properties['source'];
    if (process != null && source != null) {
      // TODO(johnmccutchan): Support better post process setup.
      Texture2D colorTexture = globalResources.findColorTarget(source);
      Map arguments = {
                       'textures': [colorTexture],
                       'samplers': [_npotSampler],
      };
      SpectrePost.pass(process, layer.renderTarget, arguments);
    }
  }

  void _setupLayer(Layer layer) {
    device.context.setRenderTarget(layer.renderTarget);
    if (layer.clearColor == true) {
      num r = layer.clearColorR;
      num g = layer.clearColorG;
      num b = layer.clearColorB;
      num a = layer.clearColorA;
      device.context.clearColorBuffer(r, g, b, a);
    }
    if (layer.clearDepth == true) {
      num v = layer.clearDepthValue;
      device.context.clearDepthBuffer(v);
    }
  }

  void render(List<Drawable> drawables, Camera camera, Viewport viewport) {
    device.configureDeviceChild(frontBufferViewport, {
      'width': frontBuffer.width,
      'height': frontBuffer.height,
    });
    device.context.setViewport(viewport);
    List<Drawable> visibleSet;
    visibleSet = _determineVisibleSet(drawables, camera);
    int numLayers = layerConfig.layers.length;
    for (int layerIndex = 0; layerIndex < numLayers; layerIndex++) {
      Layer layer = layerConfig.layers[layerIndex];

      _setupLayer(layer);

      if (layer.type == 'pass') {
        _renderPassLayer(layer, drawables, camera, viewport);
      } else if (layer.type == 'fullscreen') {
        _renderFullscreenLayer(layer, drawables, camera, viewport);
      }
    }
  }

  Renderer(this.frontBuffer, this.device) {
    globalResources = new GlobalResources(this, frontBuffer);
    layerConfig = new LayerConfig(this);
    SpectrePost.init(device);
    _npotSampler = device.createSamplerState('_npotSampler', {
      'wrapS': SamplerState.TextureWrapClampToEdge,
      'wrapT': SamplerState.TextureWrapClampToEdge,
      'minFilter': SamplerState.TextureMinFilterNearest,
      'magFilter': SamplerState.TextureMagFilterNearest,
    });
    frontBufferViewport = device.createViewport('Renderer.Viewport', {
      'width': frontBuffer.width,
      'height': frontBuffer.height,
    });
  }
}
