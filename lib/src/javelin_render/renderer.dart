part of javelin_render;

class Renderer {
  Viewport frontBufferViewport;
  GlobalConfig config;

  Map<String, Mesh> meshes;
  Map<String, Shader> shaders;
  Map<String, Material> materials;
  Map<String, Texture> textures;

  void resizeHandler() {
    // Update frontBufferViewport.
  }

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
}
