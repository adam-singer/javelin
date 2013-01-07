/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

import 'dart:html';
import 'package:spectre/spectre.dart';
import 'package:javelin/javelin.dart';
import 'package:javelin/javelin_render.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:spectre/spectre_asset_pack.dart';

AssetManager assetManager;
ShaderProgram skyBoxShaderProgram;
ShaderProgram objectShaderProgram;

// Use until importer is hooked up.
ShaderProgram _makeShaderProgram(GraphicsDevice device,
                                 String name,
                                 String vertexSource,
                                 String fragmentSource) {
  VertexShader vs = device.createVertexShader('$name[VS]');
  FragmentShader fs = device.createFragmentShader('$name[FS]');
  ShaderProgram sp = device.createShaderProgram(name);
  vs.source = vertexSource;
  if (vs.compiled == false) {
    spectreLog.Error(vs.compileLog);
  }
  assert(vs.compiled == true);
  fs.source = fragmentSource;
  if (fs.compiled == false) {
    spectreLog.Error(fs.compileLog);
  }
  assert(fs.compiled == true);
  sp.vertexShader = vs;
  sp.fragmentShader = fs;
  sp.link();
  assert(sp.linked == true);
  return sp;
}

class Demo extends JavelinBaseDemo {
  Renderer renderer;

  List<Renderable> renderables = new List<Renderable>();

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
              'format': 'RGBA',
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
                'clearColorTarget': true,
                'clearColor': [1.0, 0.0, 0.0, 1.0],
                'clearDepthTarget': true,
                'clearDepth': 1.0,
              },
              {
                'name': 'alpha',
                'colorTarget': 'backBuffer',
                'depthTarget': 'depthBuffer',
                'type': 'pass',
                'sort': 'BackToFront',
                'clearColorTarget': false,
                'clearDepthTarget': false,
              },
              {
                'name': 'present',
                'colorTarget': 'frontBuffer',
                'depthTarget': 'frontBuffer',
                'type': 'fullscreen',
                'process': 'blit',
                'source': 'backBuffer',
              }
            ]
          }
    );
  }

  void setupTextures() {
    // Create Javelin textures here.
    // TODO(johnmccutchan): Add Javelin texture importer.
    Texture spaceTexture = new Texture(renderer, 'space',
                                       assetManager.assets.space);
    renderer.textures['space'] = spaceTexture;
  }

  void setupShaders() {
    // Create shader programs here.
    // TODO(johnmccutchan): Add shader program importer.
    skyBoxShaderProgram = _makeShaderProgram(
        device,
        'skyBoxShader',
        assetManager.assets.skyBoxVertexShader,
        assetManager.assets.skyBoxFragmentShader);
  }

  void setupMeshes() {
  }

  void setupMaterials() {
    Material skyBoxMaterial = new Material(renderer,
                                           'skyBoxMaterial',
                                           skyBoxShaderProgram);
    skyBoxMaterial.textures['skyBoxCubeMap'] = 'space';
    renderer.materials['skyBoxMaterial'] = skyBoxMaterial;
  }

  void setupRenderables() {
    Renderable skyBox = new Renderable(renderer, 'skyBox',
                                       assetManager.assets.skyBox,
                                       renderer.materials['skyBoxMaterial']);
    renderables.add(skyBox);
  }

  Future<JavelinDemoStatus> startup() {
    var base = super.startup();
    Completer completer = new Completer();
    base.then((_) {
      setupGlobalResources();
      setupLayers();
      setupTextures();
      setupShaders();
      setupMeshes();
      setupMaterials();
      setupRenderables();
      var status = new JavelinDemoStatus(JavelinDemoStatus.DemoStatusOKAY, '');
      completer.complete(status);
    });
    return completer.future;
  }

  void update(num time, num dt) {
    super.update(time, dt);

    renderer.render(renderables, camera, renderer.frontBufferViewport);
  }
}

main() {
  final String baseUrl = "${window.location.href.substring(0, window.location.href.length - "index.html".length)}";
  JavelinConfigStorage.init();
  CanvasElement frontBuffer = query("#webGLFrontBuffer");
  WebGLRenderingContext webGL = frontBuffer.getContext("experimental-webgl");
  GraphicsDevice device = new GraphicsDevice(webGL);
  assetManager = new AssetManager();
  DebugDrawManager debugDrawManager = new DebugDrawManager(device);
  ResourceManager resourceManager = new ResourceManager();
  registerSpectreWithAssetManager(device, assetManager);
  spectreLog = new HtmlLogger('#SpectreLog');
  resourceManager.setBaseURL(baseUrl);
  Demo demo = new Demo(frontBuffer, device, resourceManager, debugDrawManager);
  Renderer renderer = new Renderer(frontBuffer, device);
  demo.renderer = renderer;
  Future assets = assetManager.loadPack('assets', '$baseUrl/assets.pack');
  assets.then((_) {
    demo.startup().then((_) {
      demo.run();
    });
  });
}