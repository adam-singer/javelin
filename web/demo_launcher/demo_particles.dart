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
class JavelinParticlesDemo extends JavelinBaseDemo {
  SingleArrayMesh _particlesMesh;
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

  Float32Array _particlesVertexData;

  ParticleSystemBackend _particles;

  int _numParticles;
  int _particleVertexSize;

  JavelinParticlesDemo(Element element, GraphicsDevice device, ResourceManager resourceManager, DebugDrawManager debugDrawManager) : super(element, device, resourceManager, debugDrawManager) {
    _numParticles = 100;
    _particleVertexSize = 6;
    _particles = new ParticleSystemBackendDVM(_numParticles);
    // Position+Color
    _particlesVertexData = new Float32Array(_numParticles*_particleVertexSize);
    for (int i = 0; i < _numParticles; i++) {
      int index = i * _particleVertexSize;
      _particlesVertexData[index+0] = 0.0;
      _particlesVertexData[index+1] = 0.0;
      _particlesVertexData[index+2] = 0.0;

      // Color
      _particlesVertexData[index+3] = 1.0;
      _particlesVertexData[index+4] = 0.0;
      _particlesVertexData[index+5] = 0.0;
      if (i > ((_numParticles ~/ 3) * 2)) {
        _particlesVertexData[index+3] = 0.0;
        _particlesVertexData[index+4] = 0.0;
        _particlesVertexData[index+5] = 1.0;
      } else if (i > (_numParticles ~/ 3)) {
        _particlesVertexData[index+3] = 0.0;
        _particlesVertexData[index+4] = 1.0;
        _particlesVertexData[index+5] = 0.0;
      }
    }
  }

  String get demoDescription => 'Particles';

  Future<JavelinDemoStatus> startup() {
    Future<JavelinDemoStatus> base = super.startup();

    _particlesMesh = device.createSingleArrayMesh('Particles Mesh');
    _particlesMesh.vertexArray.allocate(_numParticles*_particleVertexSize*4,
                                        SpectreBuffer.UsageStream);
    _particlesMesh.attributes['vPosition'] = new SpectreMeshAttribute(
        'vPosition',
        'float',
        3,
        0,
        24,
        false);
    _particlesMesh.attributes['vColor'] = new SpectreMeshAttribute(
        'vColor',
        'float',
        3,
        12,
        24,
        false);

    int vertexStride = _particleVertexSize*4;
    _particlesInputLayoutHandle = device.createInputLayout('Particles.IL');
    _particlesInputLayoutHandle.mesh = _particlesMesh;
    _particlesVSResourceHandle = resourceManager.registerResource('/shaders/simple_particle.vs');
    _particlesFSResourceHandle = resourceManager.registerResource('/shaders/simple_particle.fs');
    _particlesVSHandle = device.createVertexShader('Particle Vertex Shader',{});
    _particlesFSHandle = device.createFragmentShader('Particle Fragment Shader', {});
    _particlePointSpriteResourceHandle = resourceManager.registerResource('/textures/particle.png');
    _particlePointSpriteHandle = device.createTexture2D('Particle Texture', { 'width': 128, 'height': 128, 'textureFormat' : Texture.FormatRGBA, 'pixelFormat': Texture.FormatRGBA, 'pixelType': Texture.PixelTypeU8});
    _particlePointSpriteSamplerHandle = device.createSamplerState('Particle Sampler', {'wrapS':SamplerState.TextureWrapClampToEdge, 'wrapT':SamplerState.TextureWrapClampToEdge,'minFilter':SamplerState.TextureMagFilterNearest,'magFilter':SamplerState.TextureMagFilterLinear});
    _particleDepthStateHandle = device.createDepthState('Particle Depth State', {});
    _particleBlendStateHandle = device.createBlendState('Particle Blend State', {'blendEnable':true, 'blendSourceColorFunc': BlendState.BlendSourceShaderAlpha, 'blendDestColorFunc': BlendState.BlendSourceShaderInverseAlpha, 'blendSourceAlphaFunc': BlendState.BlendSourceShaderAlpha, 'blendDestAlphaFunc': BlendState.BlendSourceShaderInverseAlpha});
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
      _particlesShaderProgramHandle = device.createShaderProgram('Particle.SP', {});
      _particlesShaderProgramHandle.vertexShader = _particlesVSHandle;
      _particlesShaderProgramHandle.fragmentShader = _particlesFSHandle;
      _particlesShaderProgramHandle.link();
      assert(_particlesShaderProgramHandle.linked == true);
      _particlesInputLayoutHandle.shaderProgram = _particlesShaderProgramHandle;
      immediateContext.updateTexture2DFromResource(_particlePointSpriteHandle, _particlePointSpriteResourceHandle, resourceManager);
      immediateContext.generateMipmap(_particlePointSpriteHandle);
      complete.complete(new JavelinDemoStatus(JavelinDemoStatus.DemoStatusOKAY, ''));
    });
    return complete.future;
  }

  Future<JavelinDemoStatus> shutdown() {
    Future<JavelinDemoStatus> base = super.shutdown();
    _particlesVertexData = null;
    resourceManager.batchDeregister([_particlesVSResourceHandle, _particlesFSResourceHandle, _particlePointSpriteResourceHandle]);
    device.batchDeleteDeviceChildren([_particlesMesh, _particlesShaderProgramHandle, _particlesVSHandle, _particlesFSHandle, _particlesInputLayoutHandle, _particlePointSpriteHandle, _particleDepthStateHandle, _particleBlendStateHandle, _particlePointSpriteSamplerHandle]);
    return base;
  }

  void updateParticles() {
    _particlesMesh.vertexArray.uploadSubData(0, _particlesVertexData);
  }

  void drawParticles() {
    device.context.setInputLayout(_particlesInputLayoutHandle);
    device.context.setVertexBuffers(0, [_particlesMesh.vertexArray]);
    device.context.setIndexBuffer(null);
    device.context.setDepthState(_particleDepthStateHandle);
    device.context.setBlendState(_particleBlendStateHandle);
    device.context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyPoints);
    device.context.setShaderProgram(_particlesShaderProgramHandle);
    device.context.setTextures(0, [_particlePointSpriteHandle]);
    device.context.setSamplers(0, [_particlePointSpriteSamplerHandle]);
    device.context.setConstant('projectionViewTransform', projectionViewTransform);
    device.context.setConstant('projectionTransform', projectionTransform);
    device.context.setConstant('viewTransform', viewTransform);
    device.context.setConstant('normalTransform', normalTransform);
    device.context.draw(_numParticles, 0);
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
    _particles.update();
    _particles.copyPositions(_particlesVertexData, _particleVertexSize);
    updateParticles();
    Profiler.exit();

    Profiler.exit(); // Demo update

    drawGrid(20);
    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);

    Profiler.enter('Demo draw');
    drawParticles();
    Profiler.exit();

  }
}
