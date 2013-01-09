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

part of javelin;

class JavelinLauncher {
  final GameLoop gameLoop;
  final GraphicsDevice device;
  final GraphicsContext context;
  final DebugDrawManager debugDrawManager;
  final AssetManager assetManager;
  final Renderer renderer;
  final String baseUrl;
  final Map<String, JavelinApplicationFactory> applications
      = new Map<String, JavelinApplicationFactory>();

  JavelinApplication _currentApplication;

  JavelinLauncher(this.gameLoop, this.device, this.context,
                  this.debugDrawManager, this.assetManager,
                  this.renderer, this.baseUrl);

  void _hookApplication(JavelinApplication application) {
    gameLoop.onUpdate = application.onUpdate;
    gameLoop.onResize = application.onResize;

  }

  void _unhookApplication() {
    gameLoop.onUpdate = null;
    gameLoop.onResize = null;
  }

  Future<JavelinApplication> _launch(String applicationName) {
    JavelinApplicationFactory factory = applications[applicationName];

    if (factory == null) {
      spectreLog.Error('$applicationName does not exist.');
      return new Future.immediate(null);
    }
    JavelinApplication application = factory(applicationName, renderer,
                                             gameLoop, device,
                                             context, debugDrawManager,
                                             this, assetManager);
    if (application == null) {
      spectreLog.Error('$applicationName could not be constructed.');
      return new Future.immediate(null);
    }

    Completer completer = new Completer();
    Future assets = application.loadAssets();

    assets.then((assetpacks) {
      if (assetpacks == null) {
        spectreLog.Error('$applicationName assets failed to load.');
        completer.complete(null);
        return;
      }
      spectreLog.Info('$applicationName assets loaded.');
      Future applicationLaunched = application.launch();
      applicationLaunched.then((app) {
        if (app == null) {
          spectreLog.Error('$applicationName failed to launch.');
          completer.complete(null);
          return;
        }
        spectreLog.Info('$applicationName launched.');
        _currentApplication = application;
        _hookApplication(_currentApplication);
        completer.complete(application);
      });
    });
    return completer.future;
  }

  Future<JavelinApplication> launch(String applicationName) {
    Future shutdownFuture;
    if (_currentApplication != null) {
      _unhookApplication();
      spectreLog.Info('${_currentApplication.name} shutting down.');
      shutdownFuture = _currentApplication.shutdown();
    }
    if (shutdownFuture != null) {
      Completer completer = new Completer();
      String name = _currentApplication.name;
      _currentApplication = null;
      shutdownFuture.then((application) {
        if (application == null) {
          spectreLog.Error('$name failed to shutdown.');
          completer.complete(null);
          return;
        }
        spectreLog.Info('$name shutdown.');
        Future assetsUnloaded = application.unloadAssets();
        assetsUnloaded.then((application) {
          if (application == null) {
            spectreLog.Error('$name asset unload fail.');
            _currentApplication = null;
            completer.complete(null);
            return;
          }
          spectreLog.Info('$name unloaded assets.');
          _launch(applicationName).then((_) {
            completer.complete(_currentApplication);
          });
        });
      });
      return completer.future;
    } else {
      return _launch(applicationName);
    }
  }
}