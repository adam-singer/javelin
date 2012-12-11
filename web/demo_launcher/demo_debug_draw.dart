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
part of javelin_demo_launcher;
class JavelinDebugDrawTest extends JavelinBaseDemo {

  Map<String, vec4> _colors;
  vec3 _origin;
  vec3 _unitX;
  vec3 _unitY;
  vec3 _unitZ;
  mat4 _rotateX;
  mat4 _rotateY;
  mat4 _rotateZ;
  num _angle;
  num _scale;
  JavelinDebugDrawTest(Element element, GraphicsDevice device, ResourceManager resourceManager, DebugDrawManager debugDrawManager) : super(element, device, resourceManager, debugDrawManager) {
    _colors = new Map<String, vec4>();
    _colors['Red'] = new vec4(1.0, 0.0, 0.0, 1.0);
    _colors['Green'] = new vec4(0.0, 1.0, 0.0, 1.0);
    _colors['Blue'] = new vec4(0.0, 0.0, 1.0, 1.0);
    _colors['Gray'] = new vec4(0.3, 0.3, 0.3, 1.0);
    _colors['White'] = new vec4(1.0, 1.0, 1.0, 1.0);
    _colors['Orange'] = new vec4(1.0, 0.6475, 0.0, 1.0);
    _origin = new vec3(0.0, 0.0, 0.0);
    _unitX = new vec3(1.0, 0.0, 0.0);
    _unitY = new vec3(0.0, 1.0, 0.0);
    _unitZ = new vec3(0.0, 0.0, 1.0);
    _angle = 0.0;
    _scale = 0.0;
    _rotateX = new mat4.identity();
    _rotateY = new mat4.identity();
    _rotateZ = new mat4.identity();
  }

  Future<JavelinDemoStatus> startup() {
    Future<JavelinDemoStatus> base = super.startup();
    print('Startup');
    return base;
  }

  Future<JavelinDemoStatus> shutdown() {
    Future<JavelinDemoStatus> base = super.shutdown();
    return base;
  }

  void update(num time, num dt) {
    super.update(time, dt);


    if (keyboard.isDown(JavelinKeyCodes.KeyR)) {
      num x = mouse.X.toDouble();
      num y = mouse.Y.toDouble();
      vec3 rayNear = new vec3.zero();
      vec3 rayFar = new vec3.zero();
      bool r;
      r = pickRay(projectionViewMatrix, 0, viewportWidth, 0, viewportHeight,
                  x, y, rayNear, rayFar);
      if (r == false) {
        print('shit');
      }
      debugDrawManager.addLine(rayNear, rayFar, _colors['White'], 5.0);
      debugDrawManager.addCross(rayNear, _colors['Gray'], 1.0, 5.0);
      debugDrawManager.addCross(rayFar, _colors['Orange'], 1.0, 5.0);
    }

    _angle += dt * 3.14159;
    _scale = (sin(_angle) + 1.0)/2.0;
    _rotateX.setRotationX(_angle);
    _rotateY.setRotationY(_angle);
    _rotateZ.setRotationZ(_angle);

    // Global Axis
    debugDrawManager.addLine(_origin, _unitX.scaled(20.0), _colors['Red']);
    debugDrawManager.addLine(_origin, _unitY.scaled(20.0), _colors['Green']);
    debugDrawManager.addLine(_origin, _unitZ.scaled(20.0), _colors['Blue']);


    // Rotating transformations
    {
      mat4 T = null;
      T = new mat4.translationRaw(5.0, 0.0, 0.0) * _rotateX;
      debugDrawManager.addAxes(T, 4.0);
      T = new mat4.translationRaw(0.0, 5.0, 0.0) * _rotateY;
      debugDrawManager.addAxes(T, 4.0);
      T = new mat4.translationRaw(0.0, 0.0, 5.0) * _rotateZ;
      debugDrawManager.addAxes(T, 4.0);
    }


    // Rotating circles
    {
      debugDrawManager.addCircle(new vec3(0.0, 10.0, 0.0), _rotateY.transformed3(_unitX), 3.14, _colors['Red']);
      debugDrawManager.addCircle(new vec3(0.0, 0.0, 10.0), _rotateZ.transformed3(_unitY), 3.14, _colors['Green']);
      debugDrawManager.addCircle(new vec3(10.0, 0.0, 0.0), _rotateX.transformed3(_unitZ), 3.14, _colors['Blue']);
    }


    // AABB and a line from min to max
    {
      debugDrawManager.addAABB(new vec3(5.0, 5.0, 5.0), new vec3(10.0, 10.0, 10.0), _colors['Gray']);
      debugDrawManager.addCross(new vec3(5.0, 5.0, 5.0), _colors['White']);
      debugDrawManager.addCross(new vec3(10.0, 10.0, 10.0), _colors['White']);
      debugDrawManager.addLine(new vec3(5.0, 5.0, 5.0), new vec3(10.0, 10.0, 10.0), _colors['Orange']);
    }

    // Spheres
    {
      num radius = _scale * 2.0 + 1.0;
      debugDrawManager.addSphere(_unitX.scaled(22.0), radius, _colors['Red']);
      debugDrawManager.addSphere(_unitY.scaled(22.0), radius, _colors['Green']);
      debugDrawManager.addSphere(_unitZ.scaled(22.0), radius, _colors['Blue']);
    }
    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
  }
}
