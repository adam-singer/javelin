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

// Examples:
import 'sky_box_example.dart';

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
  final Renderer renderer = new Renderer(frontBuffer, device);
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