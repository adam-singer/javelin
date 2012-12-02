part of javelin_render;

class GlobalResources {
  final Renderer renderer;
  final CanvasElement frontBuffer;
  final Map<String, Texture2D> _colorTargets = new Map<String, Texture2D>();
  final Map<String, RenderBuffer> _depthTargets = new Map<String, RenderBuffer>();
  final List<RenderTarget> _renderTargets = new List<RenderTarget>();

  GlobalResources(this.renderer, this.frontBuffer);

  void _clearTargets() {
    _colorTargets.forEach((_, t) {
      renderer.device.deleteDeviceChild(t);
    });
    _colorTargets.clear();
    _depthTargets.forEach((_, t) {
      renderer.device.deleteDeviceChild(t);
    });
    _depthTargets.clear();
    _renderTargets.forEach((t) {
      renderer.device.deleteDeviceChild(t);
    });
    _renderTargets.clear();
  }

  void _makeColorTarget(Map target) {
    String name = target['name'];
    assert(name != null);
    Map props = {
      'width': target['width'],
      'height': target['height'],
      'pixelFormat': Texture.FormatRGBA,
      'pixelType': Texture.PixelTypeU8,
      'textureFormat': Texture.FormatRGBA,
    };
    Texture2D buffer = renderer.device.createTexture2D(name, props);
    assert(buffer != null);
    _colorTargets[name] = buffer;
  }

  void _makeDepthTarget(Map target) {
    String name = target['name'];
    assert(name != null);
    Map props = {
      'width': target['width'],
      'height': target['height'],
      'pixelFormat': Texture.FormatDepth,
      'pixelType': Texture.PixelTypeU16,
      'textureFormat': Texture.FormatDepth,
    };
    RenderBuffer buffer = renderer.device.createRenderBuffer(name, target);
    assert(buffer != null);
    _depthTargets[name] = buffer;
  }

  void _configureFrontBuffer(Map target) {
    int width = target['width'];
    int height = target['height'];
    frontBuffer.width = width;
    frontBuffer.height = height;
  }

  Texture2D findColorTarget(String colorTarget) {
    return _colorTargets[colorTarget];
  }

  RenderBuffer findDepthBuffer(String depthTarget) {
    return _depthTargets[depthTarget];
  }

  RenderTarget findRenderTarget(String colorTarget, String depthTarget,
                                String stencilTarget) {
    if (colorTarget == 'frontBuffer' ||
        depthTarget == 'frontBuffer' ||
        stencilTarget == 'frontBuffer') {
      return renderer.device.systemProvidedRenderTarget;
    }
    var colorBuffer = _colorTargets[colorTarget];
    var depthBuffer = _depthTargets[depthTarget];
    for (int i = 0; i < _renderTargets.length; i++) {
      RenderTarget rt = _renderTargets[i];
      if (rt.colorTarget == colorBuffer && rt.depthTarget == depthBuffer) {
        return rt;
      }
    }
    return null;
  }

  RenderTarget makeRenderTarget(String colorTarget, String depthTarget,
                                String stencilTarget) {
    var colorBuffer = _colorTargets[colorTarget];
    var depthBuffer = _depthTargets[depthTarget];
    String name = 'RT:';
    if (colorBuffer != null) {
      name = '$name CB: ${colorBuffer.name}';
    }
    if (depthBuffer != null) {
      name = '$name DB: ${depthBuffer.name}';
    }
    RenderTarget renderTarget = renderer.device.createRenderTarget(name, {
      'color0': colorBuffer,
      'depth': depthBuffer,
      'stencil': null,
    });
    assert(renderTarget != null);
    _renderTargets.add(renderTarget);
    return renderTarget;
  }

  void load(Map config) {
    _clearTargets();
    List<Map> targets = config['targets'];
    targets.forEach((target) {
      if (target['type'] == 'color') {
        _makeColorTarget(target);
      } else if (target['type'] == 'depth') {
        _makeDepthTarget(target);
      } else {
        assert(target['name'] == 'frontBuffer');
        _configureFrontBuffer(target);
      }
    });
  }
}
