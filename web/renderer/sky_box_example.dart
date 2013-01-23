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

library sky_box_example;
import 'dart:html';
import 'dart:async';
import 'package:spectre/spectre.dart';
import 'package:javelin/javelin.dart';
import 'package:javelin/javelin_render.dart';
import 'package:game_loop/game_loop.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:spectre/spectre_asset_pack.dart';

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
    assetManager.unloadPack('assets');
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
                'clearColor': [0.0, 0.0, 0.0, 1.0],
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
    skyBoxShaderProgram = assetManager.assets.skyBoxShader;
  }

  void teardownShaders() {
  }

  void setupMeshes() {
  }

  void setupMaterials() {
    Material skyBoxMaterial = new Material(renderer,
                                           'skyBoxMaterial',
                                           skyBoxShaderProgram);
    skyBoxMaterial.textures['skyBoxCubeMap'] = 'space';
    skyBoxMaterial.rasterizerState.cullMode = CullMode.None;
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
    debugDrawManager.update(gameLoop.dt);
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
  }

  void onRender(GameLoop gameLoop) {
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
