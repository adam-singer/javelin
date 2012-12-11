part of javelin_render;

class Layer {
  final String name;
  final String type;
  final Map properties;
  final RenderTarget renderTarget;
  bool clearColor = false;
  bool clearDepth = false;
  bool clearStencil = false;
  num clearColorR = 0.0;
  num clearColorG = 0.0;
  num clearColorB = 0.0;
  num clearColorA = 1.0;
  num clearDepthValue = 1.0;
  static const int SortModeNone = 0;
  static const int SortModeBackToFront = 1;
  static const int SortModeFrontToBack = 2;
  final int sortMode;
  Layer(this.name, this.type, this.renderTarget, this.sortMode,
        this.properties);
}

class LayerConfig {
  final Renderer renderer;
  final List<Layer> layers = new List<Layer>();

  LayerConfig(this.renderer);

  void _clearLayers() {
    layers.clear();
  }

  int _sortMode(String sortMode) {
    if (sortMode == "BackToFront") {
      return Layer.SortModeBackToFront;
    } else if (sortMode == "FrontToBack") {
      return Layer.SortModeFrontToBack;
    }
    return Layer.SortModeNone;
  }

  void _makeLayer(Map layerConfig) {
    String type = layerConfig['type'];
    RenderTarget renderTarget;
    renderTarget = renderer.globalResources.findRenderTarget(
        layerConfig['colorTarget'],
        layerConfig['depthTarget'],
        layerConfig['stencilTarget']);
    if (renderTarget == null) {
      renderTarget = renderer.globalResources.makeRenderTarget(
          layerConfig['colorTarget'],
          layerConfig['depthTarget'],
          layerConfig['stencilTarget']);
    }
    assert(renderTarget != null);
    int sortMode = _sortMode(layerConfig['sort']);
    Layer layer = new Layer(layerConfig['name'], type, renderTarget, sortMode,
                            layerConfig);
    // TODO(johnmccutchan): Support overriding clearColorR,G,B,A
    layer.clearColor = layerConfig['clearColor'] != null ?
                          layerConfig['clearColor'] : false;
    // TODO(johnmccutchan): Support overriding clearDepthVal
    layer.clearDepth = layerConfig['clearDepth'] != null ?
                          layerConfig['clearDepth'] : false;
    layers.add(layer);
  }

  void load(Map config) {
    _clearLayers();
    List<Map> layersConfig = config['layers'];
    layersConfig.forEach((layer) {
      _makeLayer(layer);
    });
  }
}