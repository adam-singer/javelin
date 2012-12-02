part of javelin_render;

class Renderer {
  final GraphicsDevice device;
  final Map<String, Mesh> meshes = new Map<String, Mesh>();
  final Map<String, Shader> shaders = new Map<String, Shader>();
  final Map<String, Material> materials = new Map<String, Material>();
  final Map<String, Texture> textures = new Map<String, Texture>();

  Viewport frontBufferViewport;
  GlobalResources globalResources;
  LayerConfig layerConfig;

  void applyCameraUniforms() {
    // Walk over shaders
  }

  int _updateVisibleSet(List<Drawable> visibleSet,
                        List<Drawable> drawables,
                        Camera camera) {
    int visibleCount = 0;
    int numDrawables = drawables.length;
    for (int i = 0; i < numDrawables; i++) {
      Drawable drawable = drawables[i];
      bool visible = true; // drawable.visibleTo(camera);
      if (!visible)
        continue;
      visibleSet[visibleCount++] = drawable;
    }
    return visibleCount;
  }

  int _sortDrawables(List<Drawable> visibleSet,
                     int numVisible,
                     String layerName) {
    int drawableCount = 0;
    for (int i = 0; i< numVisible; i++) {

    }
    drawableCount = 0;
  }

  void render(List<Drawable> drawables, Camera camera, Viewport viewport) {
    return;
    // Determine list of drawables visible from camera.
    List<Drawable> visibleSet = new List<Drawable>(drawables.length);
    int visibleCount = 0;
    visibleCount = _updateVisibleSet(visibleSet, drawables, camera);
    // Foreach layer:
      // Apply layer target settings.
      // Sort visibleSet accordingy to layer configuration.
      // Foreach drawable:
        // Draw.
  }

  Renderer(CanvasElement frontBuffer, this.device) {
    globalResources = new GlobalResources(this, frontBuffer);
    layerConfig = new LayerConfig(this);
  }
}
