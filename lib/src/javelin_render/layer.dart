part of javelin_render;

class Layer {
  final String name;
  final String type;
  final Map properties;
  final RenderTarget renderTarget;
  static const int SortModeNone = 0;
  static const int SortModeBackToFront = 1;
  static const int SortModeFrontToBack = 2;
  final int sortMode;
  Layer(this.name, this.type, this.renderTarget, this.sortMode,
        this.properties);
}

class LayerConfig {
  final Renderer renderer;
  final List<Layer> _layers = new List<Layer>();

  LayerConfig(this.renderer);

  void _clearLayers() {
    _layers.clear();
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
    _layers.add(layer);
  }

  void load(Map config) {
    _clearLayers();
    List<Map> layers = config['layers'];
    layers.forEach((layer) {
      _makeLayer(layer);
    });
  }
}