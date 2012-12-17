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
class JavelinFlyingSphere {
  final num radius;
  final DebugDrawManager debugDrawManager;
  vec3 center;
  vec3 velocity;
  vec4 color;

  JavelinFlyingSphere(this.radius, this.debugDrawManager) {
    center = new vec3.zero();
    velocity = new vec3.zero();
    color = new vec4.raw(0.5, 0.5, 0.5, 1.0);
  }

  void reset(vec3 center_, vec3 velocity_) {
    center.copyFrom(center_);
    velocity.copyFrom(velocity_);
  }

  void update() {
    vec3 acceleration = new vec3.raw(0.0, -10.0, 0.0);
    acceleration.scale(0.016);
    velocity.add(acceleration);
    vec3 temp = new vec3.copy(velocity);
    temp.scale(0.016);
    center.add(temp);
  }

  void draw() {
    debugDrawManager.addSphere(center, radius, color, 0.0, true);
  }
}

class JavelinClothDemo extends JavelinBaseDemo {
  SingleArrayIndexedMesh _particlesMesh;
  ShaderResource _particlesVSResourceHandle;
  ShaderResource _particlesFSResourceHandle;
  VertexShader _particlesVSHandle;
  FragmentShader _particlesFSHandle;
  InputLayout _particlesInputLayoutHandle;
  ShaderProgram _particlesShaderProgramHandle;
  ImageResource _particlePointSpriteResourceHandle;
  Texture2D _particlePointSpriteHandle;
  SamplerState _particlePointSpriteSamplerHandle;
  DepthState _particleDepthStateHandle;
  BlendState _particleBlendStateHandle;
  RasterizerState _particleRasterizerStateHandle;

  JavelinFlyingSphere _sphere;

  Float32Array _particlesVertexData;

  ClothSystemBackendDVM _particles;

  int _gridWidth;
  int _numParticles;
  int _particleVertexSize;

  JavelinClothDemo(Element element, GraphicsDevice device, ResourceManager resourceManager, DebugDrawManager debugDrawManager) : super(element, device, resourceManager, debugDrawManager) {
    _sphere = new JavelinFlyingSphere(1.0, debugDrawManager);
    _gridWidth = 15;
    _numParticles = _gridWidth*_gridWidth;
    _particleVertexSize = 8;
    _particles = new ClothSystemBackendDVM(_gridWidth);
    // Position+Color+TC
    _particlesVertexData = new Float32Array(_numParticles*_particleVertexSize);
    for (int i = 0; i < _gridWidth; i++) {
      for (int j = 0; j < _gridWidth; j++) {
        int index = (i + j * _gridWidth) * _particleVertexSize;
        _particlesVertexData[index+0] = 0.0;
        _particlesVertexData[index+1] = 0.0;
        _particlesVertexData[index+2] = 0.0;
        // Color
        _particlesVertexData[index+3] = 1.0;
        _particlesVertexData[index+4] = 0.0;
        _particlesVertexData[index+5] = 0.0;
        if (i + j * _gridWidth > ((_numParticles ~/ 3) * 2)) {
          _particlesVertexData[index+3] = 0.0;
          _particlesVertexData[index+4] = 0.0;
          _particlesVertexData[index+5] = 1.0;
        } else if (i + j * _gridWidth > (_numParticles ~/ 3)) {
          _particlesVertexData[index+3] = 0.0;
          _particlesVertexData[index+4] = 1.0;
          _particlesVertexData[index+5] = 0.0;
        }
        _particlesVertexData[index+6] = i / _gridWidth;
        _particlesVertexData[index+7] = j / _gridWidth;
      }
    }
  }

  Future<JavelinDemoStatus> startup() {
    Future<JavelinDemoStatus> base = super.startup();

    _particlesMesh = device.createSingleArrayIndexedMesh('Cloth Mesh');

    {
      Uint16Array indexArray = new Uint16Array((_gridWidth-1)*(_gridWidth-1)*6);
      int out = 0;
      for (int i = 0; i < _gridWidth-1; i++) {
        for (int j = 0; j < _gridWidth-1; j++) {
          int northWest = i + j * _gridWidth;
          int northEast = (i+1) + j * _gridWidth;
          int southWest = i + (j+1)*_gridWidth;
          int southEast = (i+1) + (j+1)*_gridWidth;
          indexArray[out++] = northWest;
          indexArray[out++] = northEast;
          indexArray[out++] = southWest;
          indexArray[out++] = southWest;
          indexArray[out++] = northEast;
          indexArray[out++] = southEast;
        }
      }
      _particlesMesh.indexArray.uploadData(indexArray,
                                           SpectreBuffer.UsageStatic);
    }
    _particlesMesh.vertexArray.allocate(_numParticles*_particleVertexSize*4,
                                        SpectreBuffer.UsageStream);
    int vertexStride = _particleVertexSize*4;
    _particlesMesh.attributes['vPosition'] = new SpectreMeshAttribute(
        'vPosition',
        'float',
        3,
        0,
        vertexStride,
        false);
    _particlesMesh.attributes['vColor'] = new SpectreMeshAttribute(
        'vColor',
        'float',
        3,
        12,
        vertexStride,
        false);
    _particlesMesh.attributes['vTexCoord'] = new SpectreMeshAttribute(
        'vTexCoord',
        'float',
        2,
        24,
        vertexStride,
        false);
    _particlesMesh.numIndices = (_gridWidth-1)*(_gridWidth-1)*6;
    _particlesInputLayoutHandle = device.createInputLayout('Cloth Input Layout');
    _particlesInputLayoutHandle.shaderProgram = _particlesShaderProgramHandle;
    _particlesInputLayoutHandle.mesh = _particlesMesh;
    _particlesVSResourceHandle = resourceManager.registerResource('/shaders/simple_cloth.vs');
    _particlesFSResourceHandle = resourceManager.registerResource('/shaders/simple_cloth.fs');
    _particlesVSHandle = device.createVertexShader('Cloth Vertex Shader');
    _particlesFSHandle = device.createFragmentShader('Cloth Fragment Shader');
    _particlePointSpriteResourceHandle = resourceManager.registerResource('/textures/felt.png');
    _particlePointSpriteHandle = device.createTexture2D('Cloth Texture');
    _particlePointSpriteSamplerHandle = device.createSamplerState('Cloth Sampler');
    _particlePointSpriteSamplerHandle.wrapS = SamplerState.TextureWrapClampToEdge;
    _particlePointSpriteSamplerHandle.wrapT = SamplerState.TextureWrapClampToEdge;
    _particlePointSpriteSamplerHandle.minFilter = SamplerState.TextureMagFilterNearest;
    _particlePointSpriteSamplerHandle.magFilter = SamplerState.TextureMagFilterLinear;
    _particleDepthStateHandle = device.createDepthState('Cloth Depth State');
    _particleDepthStateHandle.depthTestEnabled = true;
    _particleDepthStateHandle.depthWriteEnabled = true;
    _particleDepthStateHandle.depthComparisonOp = DepthState.DepthComparisonOpLessEqual;
    _particleBlendStateHandle = device.createBlendState('Cloth Blend State');
    _particleBlendStateHandle.blendEnable = true;
    _particleBlendStateHandle.blendSourceColorFunc = BlendState.BlendSourceShaderAlpha;
    _particleBlendStateHandle.blendDestColorFunc = BlendState.BlendSourceShaderInverseAlpha;
    _particleBlendStateHandle.blendSourceAlphaFunc =  BlendState.BlendSourceShaderAlpha;
    _particleBlendStateHandle.blendDestAlphaFunc = BlendState.BlendSourceShaderInverseAlpha;
    _particleRasterizerStateHandle = device.createRasterizerState('Cloth Rasterizer State');
    _particleRasterizerStateHandle.cullEnabled = false;

    List loadedResources = [];
    base.then((value) {
      // Once the base is done, we load our resources
      loadedResources.add(resourceManager.loadResource(_particlesVSResourceHandle));
      loadedResources.add(resourceManager.loadResource(_particlesFSResourceHandle));
      loadedResources.add(resourceManager.loadResource(_particlePointSpriteResourceHandle));
    });

    Future allLoaded = Futures.wait(loadedResources);
    Completer<JavelinDemoStatus> complete = new Completer<JavelinDemoStatus>();
    allLoaded.then((list) {
      _particlesVSHandle.source = _particlesVSResourceHandle.source;
      _particlesFSHandle.source = _particlesFSResourceHandle.source;
      _particlesShaderProgramHandle = device.createShaderProgram('Cloth Shader Program');
      _particlesShaderProgramHandle.vertexShader = _particlesVSHandle;
      _particlesShaderProgramHandle.fragmentShader = _particlesFSHandle;
      _particlesShaderProgramHandle.link();
      assert(_particlesShaderProgramHandle.linked == true);
      _particlesInputLayoutHandle.shaderProgram = _particlesShaderProgramHandle;
      int vertexStride = _particleVertexSize*4;
      _particlePointSpriteHandle.uploadElement(
          _particlePointSpriteResourceHandle.image);
      _particlePointSpriteHandle.generateMipmap();
      complete.complete(new JavelinDemoStatus(JavelinDemoStatus.DemoStatusOKAY, ''));
    });
    return complete.future;
  }

  Future<JavelinDemoStatus> shutdown() {
    Future<JavelinDemoStatus> base = super.shutdown();
    _particlesVertexData = null;
    resourceManager.batchDeregister([_particlesVSResourceHandle,
                                     _particlesFSResourceHandle,
                                     _particlePointSpriteResourceHandle]);
    device.batchDeleteDeviceChildren([_particlesMesh,
                                      _particlesShaderProgramHandle,
                                      _particlesVSHandle,
                                      _particlesFSHandle,
                                      _particlesInputLayoutHandle,
                                      _particlePointSpriteHandle,
                                      _particleDepthStateHandle,
                                      _particlePointSpriteSamplerHandle,
                                      _particleBlendStateHandle,
                                      _particleRasterizerStateHandle]);
    return base;
  }

  void updateParticles() {
    _particlesMesh.vertexArray.uploadSubData(0, _particlesVertexData);
  }

  void drawParticles() {
    device.context.setInputLayout(_particlesInputLayoutHandle);
    device.context.setIndexedMesh(_particlesMesh);
    device.context.setDepthState(_particleDepthStateHandle);
    device.context.setBlendState(_particleBlendStateHandle);
    device.context.setRasterizerState(_particleRasterizerStateHandle);
    device.context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyTriangles);
    device.context.setShaderProgram(_particlesShaderProgramHandle);
    device.context.setTextures(0, [_particlePointSpriteHandle]);
    device.context.setSamplers(0, [_particlePointSpriteSamplerHandle]);
    device.context.setConstant('projectionViewTransform', projectionViewTransform);
    device.context.setConstant('projectionTransform', projectionTransform);
    device.context.setConstant('viewTransform', viewTransform);
    device.context.setConstant('normalTransform', normalTransform);
    device.context.drawIndexedMesh(_particlesMesh);
  }

  void mouseButtonEventHandler(MouseEvent event, bool down) {
    super.mouseButtonEventHandler(event, down);
    if (event.button == JavelinMouseButtonCodes.MouseButtonLeft && down) {
      _sphere.reset(camera.position,camera.frontDirection.scale(20.0));
    }
  }

  void update(num time, num dt) {
    Profiler.enter('Demo Update');
    Profiler.enter('super.update');
    super.update(time, dt);
    Profiler.exit(); // Super.update

    {
      quat q = new quat.axisAngle(new vec3.raw(0.0, 0.0, 1.0), 0.0174532925);
      //q.rotate(_particles.gravityDirection);
    }
    Profiler.enter('particles update');
    _particles.sphereConstraints(_sphere.center, _sphere.radius);
    _particles.update();
    _particles.copyPositions(_particlesVertexData, _particleVertexSize);
    updateParticles();

    if (keyboard.isDown(JavelinKeyCodes.KeyZ)) {
      _particles.pick(3, 8, new vec3.raw(0.0, 0.0, 0.0));
    }
    Profiler.exit();

    Profiler.exit(); // Demo update

    drawGrid(20);
    _sphere.update();
    _sphere.draw();
    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);

    Profiler.enter('Demo draw');
    drawParticles();
    Profiler.exit();

  }
}
