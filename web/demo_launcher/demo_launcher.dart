/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

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

library javelin_demo_launcher;

import 'dart:html';
import 'dart:math' as Math;
import 'dart:async';
import 'package:vector_math/vector_math_browser.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_scene.dart';
import 'package:spectre/spectre_post.dart';
import 'package:javelin/javelin.dart';
import 'package:javelin/javelin_scene.dart';
import 'package:marker_prof/profiler.dart';
import 'package:marker_prof/profiler_gui.dart';
import 'package:marker_prof/profiler_client.dart';
import 'package:javelin/hfluid.dart';
import 'package:javelin/skybox.dart';
import 'particle_system.dart';

// Demos
part 'demo_empty.dart';
part 'demo_debug_draw.dart';
part 'demo_spinning_cube.dart';
part 'demo_hfluid.dart';
part 'demo_skybox.dart';
part 'demo_cloth.dart';
part 'demo_particles.dart';
part 'demo_projector.dart';

class JavelinDemoDescription {
  String name;
  Function constructDemo;
}

class JavelinDemoLaunch {
  JavelinBaseDemo _demo;
  List<JavelinDemoDescription> demos;
  ProfilerClient profilerClient;

  GraphicsDevice device;
  ResourceManager resourceManager;
  DebugDrawManager debugDrawManager;
  ProfilerTree tree;
  bool isLocked;

  void captured(List data) {
  }

  void captureControl(int command, String requester) {
    if (command == ProfilerClient.StartCapture) {
      spectreLog.Info('$requester started capture');
      Profiler.clear();
    }
    if (command == ProfilerClient.StopCapture) {
      spectreLog.Info('$requester stopped capture');
      List capture = Profiler.makeCapture();
      //spectreLog.Info('$capture');
      profilerClient.deliverCapture(requester, capture);
    }
  }

  void registerDemo(String name, Function constructDemo) {
    JavelinDemoDescription jdd = new JavelinDemoDescription();
    jdd.name = name;
    jdd.constructDemo = constructDemo;
    demos.add(jdd);
    refreshDemoList('#DemoPicker');
  }

  void webglClicked(Event ev) {
    document.query('#webGLFrontBuffer').webkitRequestPointerLock();
  }

  void pointerLockChanged(Event ev) {
    isLocked = document.query('#webGLFrontBuffer') == document.webkitPointerLockElement;
    if (_demo != null) {
      _demo.mouse.locked = isLocked;
    }
  }

  JavelinDemoLaunch() {
    _demo = null;
    demos = new List<JavelinDemoDescription>();
    tree = new ProfilerTree();
    isLocked = false;
    profilerClient = new ProfilerClient('Javelin', captured, captureControl, ProfilerClient.TypeUserApplication);
    profilerClient.connect('ws://127.0.0.1:8087/');
    document.on.pointerLockChange.add(pointerLockChanged);
    document.query('#webGLFrontBuffer').on.click.add(webglClicked);
  }

  void updateStatus(String message) {
    // the HTML library defines a global "document" variable
    document.query('#DartStatus').innerHtml = message;
  }

  void refreshDemoList(String listDiv) {
    DivElement d = document.query(listDiv);
    if (d == null) {
      return;
    }
    d.nodes.clear();
    for (final JavelinDemoDescription jdd in demos) {
      DivElement demod = new DivElement();
      demod.on.click.add((Event event) {
        switchToDemo(jdd.name);
      });
      demod.innerHtml = '${jdd.name}';
      demod.classes.add('DemoButton');
      d.nodes.add(demod);
    }
  }

  void refreshResourceManagerTable() {
    final String divName = '#ResourceManagerTable';
    DivElement d = document.query(divName);
    if (d == null) {
      return;
    }
    d.nodes.clear();
    ParagraphElement pe = new ParagraphElement();
    pe.innerHtml = 'Loaded Resources:';
    d.nodes.add(pe);
    resourceManager.children.forEach((name, resource) {
      DivElement resourceDiv = new DivElement();
      DivElement resourceNameDiv = new DivElement();
      DivElement resourceUnloadDiv = new DivElement();
      DivElement resourceLoadDiv = new DivElement();
      resourceNameDiv.innerHtml = '${name}';
      resourceLoadDiv.innerHtml = 'Reload';
      resourceLoadDiv.on.click.add((Event event) {
        resourceManager.loadResource(resource);
      });
      resourceLoadDiv.style.float = 'right';
      resourceUnloadDiv.innerHtml = 'Unload';
      resourceUnloadDiv.on.click.add((Event event) {
        resourceManager.unloadResource(resource);
      });
      resourceLoadDiv.classes.add('DemoButton');
      resourceUnloadDiv.classes.add('DemoButton');
      resourceDiv.nodes.add(resourceNameDiv);
      resourceDiv.nodes.add(resourceLoadDiv);
      //resourceDiv.nodes.add(resourceUnloadDiv);
      resourceDiv.classes.add('ResourceRow');
      d.nodes.add(resourceDiv);
    });
  }

  void refreshDeviceManagerTable() {
    final String divName = '#DeviceChildTable';
    DivElement d = document.query(divName);
    d.nodes.clear();
    ParagraphElement pe = new ParagraphElement();
    pe.innerHtml = 'Device Objects:';
    d.nodes.add(pe);
    if (d == null) {
      return;
    }
    if (_demo == null) {
      return;
    }
    var tableSortedByType = new Map<String, List<String>>();
    _demo.device.children.forEach((name, handle) {
      String type = '';
      var list = tableSortedByType[type];
      if (list == null) {
        list = tableSortedByType[type] = new List<String>();
      }
      list.add(name);
    });
    tableSortedByType.forEach((type, names) {
      DivElement label = new DivElement();
      label.text = '$type';
      label.style.fontWeight = 'bold';

      d.nodes.add(label);
      names.forEach((name) {
        DivElement resourceDiv = new DivElement();
        resourceDiv.innerHtml = '${name}';
        resourceDiv.style.marginLeft = '20px';
        d.nodes.add(resourceDiv);
      });
    });
  }

  void refreshProfileTree() {
    tree.processEvents(Profiler.events);
    Profiler.clear();
    //document.query('#ProfilerRoot').innerHTML = ProfilerTreeListGUI.buildTree(tree);
  }

  void refresh() {
    refreshResourceManagerTable();
    refreshDeviceManagerTable();
    refreshProfileTree();
  }

  void resizeHandler(Event event) {
    updateSize();
  }

  void updateSize() {
    String webGLCanvasParentName = '#MainView';
    String webGLCanvasName = '#webGLFrontBuffer';
    {
      DivElement canvasParent = document.query(webGLCanvasParentName);
      final num width = canvasParent.clientWidth;
      final num height = canvasParent.clientHeight;
      CanvasElement canvas = document.query(webGLCanvasName);
      canvas.width = width;
      canvas.height = height;
      if (_demo != null) {
        _demo.resize(width, height);
      }
    }
  }

  Future<bool> startup() {
    final String webGLCanvasParentName = '#MainView';
    final String webGLCanvasName = '#webGLFrontBuffer';
    spectreLog.Info('Started Javelin');
    CanvasElement canvas = document.query(webGLCanvasName);
    WebGLRenderingContext webGL = canvas.getContext("experimental-webgl");
    device = new GraphicsDevice(webGL);
    SpectrePost.init(device);
    debugDrawManager = new DebugDrawManager(device);
    resourceManager = new ResourceManager();
    var baseUrl = "${window.location.href.substring(0, window.location.href.length - "index.html".length)}data/";
    resourceManager.setBaseURL(baseUrl);
    Completer<bool> inited = new Completer<bool>();
    inited.complete(true);
    return inited.future;
  }
  void run() {
    updateStatus("Pick a demo: ");
    window.on.resize.add(resizeHandler);
    updateSize();
    // Start spectre
    Future<bool> started = startup();
    started.then((value) {
      spectreLog.Info('Javelin Running');
      device.context.clearColorBuffer(0.0, 0.0, 0.0, 1.0);
      device.context.clearDepthBuffer(1.0);
      registerDemo('Empty', () { return new JavelinEmptyDemo(document.query('#webGLFrontBuffer'), device, resourceManager, debugDrawManager); });
      registerDemo('Debug Draw Test', () { return new JavelinDebugDrawTest(document.query('#webGLFrontBuffer'),device, resourceManager, debugDrawManager); });
      registerDemo('Spinning Mesh', () { return new JavelinSpinningCube(document.query('#webGLFrontBuffer'),device, resourceManager, debugDrawManager); });
      registerDemo('Height Field Fluid', () { return new JavelinHFluidDemo(document.query('#webGLFrontBuffer'),device, resourceManager, debugDrawManager); });
      //registerDemo('Skybox', () { return new JavelinSkyboxDemo(device, resourceManager, debugDrawManager); });
      registerDemo('Cloth', () { return new JavelinClothDemo(document.query('#webGLFrontBuffer'),device, resourceManager, debugDrawManager); });
      registerDemo('Particles', () { return new JavelinParticlesDemo(document.query('#webGLFrontBuffer'),device, resourceManager, debugDrawManager); });
      //registerDemo('Normal Map', () { return new JavelinNormalMap(device, resourceManager, debugDrawManager); });
      registerDemo('Scene', () { return new JavelinProjector(document.query('#webGLFrontBuffer'),device, resourceManager, debugDrawManager); });
      switchToDemo(JavelinConfigStorage.get('Javelin.demo'));
      window.setInterval(refresh, 1000);
    });
  }

  void switchToDemo(String name) {
    Future shut;
    if (_demo != null) {
      shut = _demo.shutdown();
    } else {
      shut = new Future.immediate(new JavelinDemoStatus(JavelinDemoStatus.DemoStatusOKAY, ''));
    }
    shut.then((statusValue) {
      device.context.reset();
      _demo = null;
      for (final JavelinDemoDescription jdd in demos) {
        if (jdd.name == name) {
          _demo = jdd.constructDemo();
          break;
        }
      }
      if (_demo != null) {
        print('Starting demo $name');
        Future<JavelinDemoStatus> started = _demo.startup();
        started.then((sv) {
          print('Running demo $name');
          updateSize();
          _demo.mouse.locked = isLocked;
          _demo.run();
          JavelinConfigStorage.set('Javelin.demo', name, true);
          {
            DivElement elem = document.query('#DemoDescription');
            elem.nodes.clear();
            elem.innerHtml = '<p>${_demo.demoDescription}</p>';
          }
          {
            DivElement elem = document.query('#DemoUI');
            elem.nodes.clear();
            Element e = _demo.makeDemoUI();
            if (e != null) {
              elem.nodes.add(e);
            }
          }
        });
      }
    });
  }
}

void main() {
  Profiler.init();
  JavelinConfigStorage.init();
  // Comment out the following line to reset defaults
  //JavelinConfigStorage.load();
  //JavelinConfigStorage.set('demo.postprocess', 'blit', true);
  spectreLog = new HtmlLogger('#SpectreLog');
  {
    var e = document.query('#ResourceTableHeader');
    var rt = document.query('#ResourceTable');
    var rth = document.query('#ResourceTableHolder');
    var collapsed = false;
    var heightValue = e.style.height;
    print('$heightValue');
    rth.on.transitionEnd.add((event) {
      if (collapsed == false) {
      } else {

      }
      print('transition ended');
    });
    e.on.click.add((event) {
      if (collapsed == false) {
        e.style.height = "30px";
        rt.style.display = "none";
      } else {
        e.style.height = '${heightValue}px';
        rt.style.display = "-webkit-flex";
      }
      collapsed = !collapsed;
    });
  }
  new JavelinDemoLaunch().run();
}