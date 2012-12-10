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
class JavelinHFluidDemo extends JavelinBaseDemo {
  HeightFieldFluid _fluid;
  VertexBuffer _fluidVBOHandle;
  int _centerColumnIndex;
  ShaderResource _fluidVSResourceHandle;
  ShaderResource _fluidFSResourceHandle;
  VertexShader _fluidVSHandle;
  FragmentShader _fluidFSHandle;
  InputLayout _fluidInputLayoutHandle;
  ShaderProgram _fluidShaderProgramHandle;
  RasterizerState rs;
  DepthState ds;
  Float32Array _fluidVertexData;
  int _fluidNumVertices;
  Float32Array _lightDirection;
  ConfigUI _configUI;
  JavelinHFluidDemo(Element element, GraphicsDevice device, ResourceManager resourceManager, DebugDrawManager debugDrawManager) : super(element, device, resourceManager, debugDrawManager) {
    _fluid = new HeightFieldFluid(50, 0.5);
    _centerColumnIndex = 12;
    _configUI = new ConfigUI();
    _configUI.addItem({
      'name': 'demo.hfluid.dropheight',
      'widget': 'slider',
      'settings': {
        'min': 0.0,
        'max': 3.0,
        'step': 0.1
      }
    });
    _configUI.addItem({
      'name': 'demo.hfluid.waveheight',
      'widget': 'slider',
      'settings': {
        'min': 0.0,
        'max': 3.0,
        'step': 0.1
      }
    });
    _configUI.build();
  }

  Future<JavelinDemoStatus> startup() {
    Future<JavelinDemoStatus> base = super.startup();
    _lightDirection = new Float32Array(3);
    int numColumns = (_fluid.columnsWide-2)*(_fluid.columnsWide-2);
    int vboSize = (numColumns)*2*6; // two triangles per column, triangle needs 3 vertices and 3 normals
    _fluidNumVertices = (numColumns)*2*3;
    // Each vertex/normal needs three floats
    vboSize *= 3;
    _fluidVertexData = new Float32Array(vboSize);
    // Each float needs 4 bytes
    vboSize *= 4;
    _fluidVBOHandle = device.createVertexBuffer('Fluid Vertex Buffer', {'usage':'stream', 'size':vboSize});
    _fluidVSResourceHandle = resourceManager.registerResource('/shaders/simple_fluid.vs');
    _fluidFSResourceHandle = resourceManager.registerResource('/shaders/simple_fluid.fs');
    _fluidVSHandle = device.createVertexShader('Fluid Vertex Shader',{});
    _fluidFSHandle = device.createFragmentShader('Fluid Fragment Shader', {});

    rs = device.getDeviceChild('RasterizerState.CullDisabled');
    ds = device.getDeviceChild('DepthState.TestWrite');

    List loadedResources = [];
    base.then((value) {
      // Once the base is done, we load our resources
      loadedResources.add(resourceManager.loadResource(_fluidVSResourceHandle));
      loadedResources.add(resourceManager.loadResource(_fluidFSResourceHandle));
    });

    Future allLoaded = Futures.wait(loadedResources);
    Completer<JavelinDemoStatus> complete = new Completer<JavelinDemoStatus>();
    allLoaded.then((list) {
      immediateContext.compileShaderFromResource(_fluidVSHandle, _fluidVSResourceHandle, resourceManager);
      immediateContext.compileShaderFromResource(_fluidFSHandle, _fluidFSResourceHandle, resourceManager);
      _fluidShaderProgramHandle = device.createShaderProgram('Fluid Shader Program', { 'VertexProgram': _fluidVSHandle, 'FragmentProgram': _fluidFSHandle});
      int vertexStride = 2*3*4;
      var elements = [new InputElementDescription('vPosition', GraphicsDevice.DeviceFormatFloat3, vertexStride, 0, 0),
                      new InputElementDescription('vNormal', GraphicsDevice.DeviceFormatFloat3, vertexStride, 0, 12)];
      _fluidInputLayoutHandle = device.createInputLayout('Fluid Input Layout', {'elements':elements, 'shaderProgram':_fluidShaderProgramHandle});
      complete.complete(new JavelinDemoStatus(JavelinDemoStatus.DemoStatusOKAY, ''));
    });
    return complete.future;
  }

  String get demoDescription => 'Height Field Fluid';

  Element makeDemoUI() {
    return _configUI.root;
  }

  Future<JavelinDemoStatus> shutdown() {
    Future<JavelinDemoStatus> base = super.shutdown();
    _fluidVertexData = null;
    resourceManager.batchDeregister([_fluidVSResourceHandle, _fluidFSResourceHandle]);
    device.batchDeleteDeviceChildren([_fluidVBOHandle, _fluidShaderProgramHandle, _fluidVSHandle, _fluidFSHandle, _fluidInputLayoutHandle]);
    return base;
  }

  void _drawFluid() {
    device.context.setInputLayout(_fluidInputLayoutHandle);
    device.context.setVertexBuffers(0, [_fluidVBOHandle]);
    device.context.setIndexBuffer(null);
    device.context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyTriangles);
    device.context.setShaderProgram(_fluidShaderProgramHandle);
    device.context.setDepthState(ds);
    device.context.setRasterizerState(rs);
    device.context.setUniformMatrix4('projectionViewTransform', projectionViewTransform);
    device.context.setUniformMatrix4('projectionTransform', projectionTransform);
    device.context.setUniformMatrix4('viewTransform', viewTransform);
    device.context.setUniformMatrix4('normalTransform', normalTransform);
    device.context.setUniformVector3('lightDir', _lightDirection);
    device.context.draw(_fluidNumVertices, 0);
  }

  void _updateFluidVertexData() {
    _fluidVBOHandle.uploadData(_fluidVertexData, _fluidVBOHandle.usage);
  }

  void _buildFluidVertexData() {
    final num scale = 1.0;
    int vertexDataIndex = 0;
    vec3 n1 = new vec3.zero();
    vec3 v0 = new vec3.zero();
    vec3 v1 = new vec3.zero();
    vec3 v2 = new vec3.zero();
    for (int i = 1; i < _fluid.columnsWide-1; i++) {
      for (int j = 1; j < _fluid.columnsWide-1; j++) {
        final int index = _fluid.columnIndex(i, j);
        final int indexEast = _fluid.columnIndex(i+1, j);
        final int indexNorth = _fluid.columnIndex(i, j+1);
        final int indexNorthEast = _fluid.columnIndex(i+1, j+1);
        final num height = _fluid.columns[index];
        final num heightEast = _fluid.columns[indexEast];
        final num heightNorth = _fluid.columns[indexNorth];
        final num heightNorthEast = _fluid.columns[indexNorthEast];
        final double dI = i.toDouble();
        final double dJ = j.toDouble();
        final double dI1 = dI+1.0;
        final double dJ1 = dJ+1.0;

        {
          v0.setComponents(i.toDouble(), height, j.toDouble());
          v1.setComponents(i.toDouble()+1.0, heightEast, j.toDouble());
          v2.setComponents(i.toDouble()+1.0, heightNorthEast, j.toDouble()+1.0);
          v2.sub(v1);
          v1.sub(v0);
          v2.cross(v1, n1);
          n1.normalize();
        }
        // v0
        _fluidVertexData[vertexDataIndex++] = dI;
        _fluidVertexData[vertexDataIndex++] = height;
        _fluidVertexData[vertexDataIndex++] = dJ;
        _fluidVertexData[vertexDataIndex++] = n1.x;
        _fluidVertexData[vertexDataIndex++] = n1.y;
        _fluidVertexData[vertexDataIndex++] = n1.z;

        // v1
        _fluidVertexData[vertexDataIndex++] = dI1;
        _fluidVertexData[vertexDataIndex++] = heightEast;
        _fluidVertexData[vertexDataIndex++] = dJ;
        _fluidVertexData[vertexDataIndex++] = n1.x;
        _fluidVertexData[vertexDataIndex++] = n1.y;
        _fluidVertexData[vertexDataIndex++] = n1.z;
        // v2
        _fluidVertexData[vertexDataIndex++] = dI1;
        _fluidVertexData[vertexDataIndex++] = heightNorthEast;
        _fluidVertexData[vertexDataIndex++] = dJ1;
        _fluidVertexData[vertexDataIndex++] = n1.x;
        _fluidVertexData[vertexDataIndex++] = n1.y;
        _fluidVertexData[vertexDataIndex++] = n1.z;
        {
          v1.setComponents(i.toDouble()+1.0, heightNorthEast, j.toDouble()+1.0);
          v2.setComponents(i.toDouble(), heightNorth, j.toDouble()+1.0);
          v2.sub(v1);
          v1.sub(v0);
          v2.cross(v1, n1);
          n1.normalize();
        }
        // v0
        _fluidVertexData[vertexDataIndex++] = dI;
        _fluidVertexData[vertexDataIndex++] = height;
        _fluidVertexData[vertexDataIndex++] = dJ;
        _fluidVertexData[vertexDataIndex++] = n1.x;
        _fluidVertexData[vertexDataIndex++] = n1.y;
        _fluidVertexData[vertexDataIndex++] = n1.z;
        // v1
        _fluidVertexData[vertexDataIndex++] = dI1;
        _fluidVertexData[vertexDataIndex++] = heightNorthEast;
        _fluidVertexData[vertexDataIndex++] = dJ1;
        _fluidVertexData[vertexDataIndex++] = n1.x;
        _fluidVertexData[vertexDataIndex++] = n1.y;
        _fluidVertexData[vertexDataIndex++] = n1.z;
        // v2
        _fluidVertexData[vertexDataIndex++] = dI;
        _fluidVertexData[vertexDataIndex++] = heightNorth;
        _fluidVertexData[vertexDataIndex++] = dJ1;
        _fluidVertexData[vertexDataIndex++] = n1.x;
        _fluidVertexData[vertexDataIndex++] = n1.y;
        _fluidVertexData[vertexDataIndex++] = n1.z;
      }
    }
  }

  void _makeWave(int column, num h) {
    int half = _fluid.columnsWide~/2;
    int quarter = half~/2;
    for (int j = quarter; j < half+quarter; j++) {
      int columnIndex = _fluid.columnIndex(column, j);
      _fluid.columns[columnIndex] += h;
    }
  }

  void _makeDrop(int column, num h) {
    int columnIndex1 = _fluid.columnIndex(column, column);
    int columnIndex2 = _fluid.columnIndex(column+1, column);
    int columnIndex3 = _fluid.columnIndex(column, column+1);
    int columnIndex4 = _fluid.columnIndex(column+1, column+1);
    _fluid.columns[columnIndex1] += h;
    _fluid.columns[columnIndex2] += h;
    _fluid.columns[columnIndex3] += h;
    _fluid.columns[columnIndex4] += h;
  }

  void update(num time, num dt) {
    Profiler.enter('Demo Update');
    Profiler.enter('super.update');
    super.update(time, dt);
    Profiler.exit();

    if (keyboard.pressed(JavelinKeyCodes.KeyP)) {
      _makeWave(3, JavelinConfigStorage.get('demo.hfluid.waveheight'));
      _makeWave(2, JavelinConfigStorage.get('demo.hfluid.waveheight'));
    }
    if (keyboard.pressed(JavelinKeyCodes.KeyO)) {
      _makeDrop(_centerColumnIndex, JavelinConfigStorage.get('demo.hfluid.dropheight'));
    }

    //drawGrid(20);
    Profiler.enter('fluid update');
    _fluid.update();
    _fluid.setReflectiveBoundaryAll();
    //_fluid.setFlowBoundary(HeightFieldFluid.BoundaryNorth, -0.001);
    //_fluid.setFlowBoundary(HeightFieldFluid.BoundarySouth, -0.05);
    //_fluid.setReflectiveBoundary(HeightFieldFluid.BoundaryNorth);
    //_fluid.setReflectiveBoundary(HeightFieldFluid.BoundaryWest);
    //_fluid.setReflectiveBoundary(HeightFieldFluid.BoundarySouth);
    //_fluid.setReflectiveBoundary(HeightFieldFluid.BoundaryEast);
    //_fluid.setOpenBoundary(HeightFieldFluid.BoundaryEast);
    //_fluid.setOpenBoundaryAll();
    Profiler.exit();

    Stopwatch sw = new Stopwatch();
    Profiler.enter('fluid prepare to draw');
    sw.start();
    _buildFluidVertexData();
    sw.stop();
    //print(sw.elapsed());
    _updateFluidVertexData();
    Profiler.exit();

    {
      vec3 lightDirection = new vec3(1.0, -1.0, 1.0);
      lightDirection.normalize();
      normalMatrix.rotate3(lightDirection);
      lightDirection.normalize();
      lightDirection.copyIntoArray(_lightDirection);
    }
    Profiler.enter('fluid draw');
    _drawFluid();
    Profiler.exit();

    Profiler.exit();
    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
    Profiler.exit();
  }
}
