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
import 'package:game_loop/game_loop.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:spectre/spectre_asset_pack.dart';

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

class SkyBoxExample extends JavelinApplication {
  final List<Renderable> renderables = new List<Renderable>();
  final Camera camera = new Camera();
  final cameraController = new MouseKeyboardCameraController();
  ShaderProgram skyBoxShaderProgram;
  ShaderProgram objectShaderProgram;
  SkyBoxExample(String name,
                Renderer renderer,
                GameLoop gameLoop,
                GraphicsDevice device,
                GraphicsContext context,
                DebugDrawManager ddm,
                JavelinLauncher launcher,
                AssetManager assetManager)
      : super(name,
              renderer,
              gameLoop,
              device,
              context,
              ddm,
              launcher,
              assetManager) {
  }

  Future loadAssets() {
    return assetManager.loadPack('assets', '${launcher.baseUrl}/assets.pack');
  }

  Future unloadAssets() {
    print('before unload:');
    print('');
    print('');
    device.dumpChildren();
    assetManager.unloadPack('assets');
    print('after unload:');
    print('');
    print('');
    device.dumpChildren();
    return new Future.immediate(this);
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

  void teardownTextures() {
    renderer.textures.remove('space');
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

  void teardownShaders() {
    device.deleteDeviceChild(skyBoxShaderProgram.vertexShader);
    device.deleteDeviceChild(skyBoxShaderProgram.fragmentShader);
    device.deleteDeviceChild(skyBoxShaderProgram);
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

  void teardownMaterials() {
    renderer.materials.remove('skyBoxMaterial');
  }

  void setupRenderables() {
    Renderable skyBox = new Renderable(renderer, 'skyBox',
                                       assetManager.assets.skyBox,
                                       renderer.materials['skyBoxMaterial']);
    renderables.add(skyBox);
  }

  Future launch() {
    assetManager.assets.forEach((k, v) {
      print('Asset: $k');
    });
    var blah = assetManager.assets.skyBox;
    assert(blah != null);
    setupGlobalResources();
    setupLayers();
    setupTextures();
    setupShaders();
    setupMeshes();
    setupMaterials();
    setupRenderables();
    return new Future.immediate(this);
  }

  Future shutdown() {
    teardownMaterials();
    teardownShaders();
    teardownTextures();
    renderables.forEach((renderable) {
      renderable.cleanup();
    });
    return new Future.immediate(this);
  }

  void onUpdate(GameLoop gameLoop) {
    cameraController.forward =
        gameLoop.keyboard.buttons[GameLoopKeyboard.W].down;
    cameraController.backward =
        gameLoop.keyboard.buttons[GameLoopKeyboard.S].down;
    cameraController.strafeLeft =
        gameLoop.keyboard.buttons[GameLoopKeyboard.A].down;
    cameraController.strafeRight =
        gameLoop.keyboard.buttons[GameLoopKeyboard.D].down;
    if (gameLoop.pointerLock.locked) {
      cameraController.accumDX = gameLoop.mouse.dx;
      cameraController.accumDY = gameLoop.mouse.dy;
    }
    cameraController.UpdateCamera(gameLoop.dt, camera);
    renderer.render(renderables, camera, renderer.frontBufferViewport);
  }

  void onResize(GameLoop gameLoop) {
  }
}

SkyBoxExample SkyBoxExampleFactory(String name,
                                   Renderer renderer,
                                   GameLoop gameLoop,
                                   GraphicsDevice device,
                                   GraphicsContext context,
                                   DebugDrawManager ddm,
                                   JavelinLauncher launcher,
                                   AssetManager assetManager) {
  return new SkyBoxExample(name, renderer, gameLoop, device, context, ddm,
                           launcher, assetManager);
}

main() {
  final CanvasElement frontBuffer = query("#webGLFrontBuffer");
  if (frontBuffer == null) {
    print('Cannot find #webGLFrontBuffer in DOM.');
    return;
  }
  WebGLRenderingContext webGL = frontBuffer.getContext("experimental-webgl");
  if (webGL == null) {
    print('WebGL not supported.');
    return;
  }
  final GraphicsDevice device = new GraphicsDevice(webGL);
  final GraphicsContext context = device.context;
  final DebugDrawManager debugDrawManager = new DebugDrawManager(device);
  final GameLoop gameLoop = new GameLoop(frontBuffer);
  final AssetManager assetManager = new AssetManager();
  Renderer renderer = new Renderer(frontBuffer, device);
  final String baseUrl = window.location.href.substring(
      0,
      window.location.href.length - "index.html".length);
  final JavelinLauncher launcher = new JavelinLauncher(gameLoop,
                                                       device,
                                                       context,
                                                       debugDrawManager,
                                                       assetManager,
                                                       renderer,
                                                       baseUrl);
  registerSpectreWithAssetManager(device, assetManager);
  spectreLog = new HtmlLogger('#SpectreLog');
  launcher.applications['SkyBox'] = SkyBoxExampleFactory;
  launcher.launch('SkyBox').then((_) {
    //launcher.launch('SkyBox');
  });
  gameLoop.start();
}