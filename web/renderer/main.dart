
import 'dart:html';
import 'package:spectre/spectre.dart';
import 'package:javelin/javelin.dart';
import 'package:javelin/javelin_render.dart';

class Demo extends JavelinBaseDemo {
  Renderer renderer;

  List<Drawable> drawables;

  Demo(Element element,
       GraphicsDevice device,
       ResourceManager resourceManager,
       DebugDrawManager debugDrawManager) :
         super(element, device, resourceManager, debugDrawManager) {
  }

  void setupGlobalResources() {
    renderer.globalResources.load(
        {
          'targets':
            [
              {
              'name': 'frontBuffer',
              'width': 640,
              'height': 480,
              },
              {
              'name': 'backBuffer',
              'type': 'color',
              'format': 'R8G8B8A8',
              'width': 640,
              'height': 480,
              },
              {
              'name': 'depthBuffer',
              'type': 'depth',
              'format': 'DEPTH32',
              'width': 640,
              'height': 480,
              },
            ],
          }
    );
  }

  void setupLayers() {
    renderer.layerConfig.load(
        {
          'layers':
            [
              {
              'name': 'opaque',
              'colorTarget': 'backBuffer',
              'depthTarget': 'depthBuffer',
              'type': 'pass',
              'sort': 'none',
              },
              {
                'name': 'alpha',
                'colorTarget': 'backBuffer',
                'depthTarget': 'depthBuffer',
                'type': 'pass',
                'sort': 'BackToFront',
              },
              {
                'name': 'present',
                'colorTarget': 'frontBuffer',
                'type': 'fullscreen',
                'source': 'backBuffer',
              }
            ]
          }
    );
    renderer.layerConfig.load(
        {
          'layers':
            [
              {
              'name': 'opaque',
              'colorTarget': 'frontBuffer',
              'depthTarget': 'frontBuffer',
              'type': 'pass',
              'sort': 'none',
              },
            ]
          }
    );
  }

  void setupShaders() {
  }

  void setupMeshes() {
  }

  void setupMaterials() {
  }

  void setupDrawables() {
  }

  Future<JavelinDemoStatus> startup() {
    var base = super.startup();
    Completer completer = new Completer();
    base.then((_) {
      setupGlobalResources();
      setupLayers();
      setupLayers();
      setupLayers();
      setupShaders();
      setupMeshes();
      setupMaterials();
      setupDrawables();
      var status = new JavelinDemoStatus(JavelinDemoStatus.DemoStatusOKAY, '');
      completer.complete(status);
    });
    return completer.future;
  }

  void update(num time, num dt) {
    super.update(time, dt);
    renderer.render(drawables, camera, renderer.frontBufferViewport);
  }
}

main() {
  JavelinConfigStorage.init();
  CanvasElement frontBuffer = query("#webGLFrontBuffer");
  WebGLRenderingContext webGL = frontBuffer.getContext("experimental-webgl");
  GraphicsDevice device = new GraphicsDevice(webGL);
  DebugDrawManager debugDrawManager = new DebugDrawManager();
  ResourceManager resourceManager = new ResourceManager();
  spectreLog = new HtmlLogger('#SpectreLog');
  var baseUrl = window.location.href.substring(0,
      window.location.href.length - "index.html".length);
  resourceManager.setBaseURL(baseUrl);
  debugDrawManager.init(device);
  Demo demo = new Demo(frontBuffer, device, resourceManager, debugDrawManager);
  Renderer renderer = new Renderer(frontBuffer, device);
  demo.renderer = renderer;
  demo.startup().then((_) {
    demo.run();
  });
}