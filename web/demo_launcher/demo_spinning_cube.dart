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
class JavelinSpinningCube extends JavelinBaseDemo {
  MeshResource cubeMeshResource;
  SingleArrayIndexedMesh cubeMesh;
  ShaderResource cubeVertexShaderResource;
  VertexShader cubeVertexShader;
  ShaderResource cubeFragmentShaderResource;
  FragmentShader cubeFragmentShader;
  ImageResource cubeTextureResource;
  ShaderProgram cubeProgram;
  RenderConfigResource renderConfigResource;
  Texture2D texture;
  SamplerState sampler;
  RasterizerState rs;
  InputLayout il;
  DepthState ds;
  Float32Array cameraTransform;
  Float32Array objectTransform;
  num _angle;
  TransformGraph _transformGraph;
  List<TransformGraphNode> _transformNodes;
  ConfigUI _configUI;
  String get demoDescription => 'Spinning Mesh';

  JavelinSpinningCube(Element element, GraphicsDevice device, ResourceManager resourceManager, DebugDrawManager debugDrawManager) : super(element, device, resourceManager, debugDrawManager) {
    cameraTransform = new Float32Array(16);
    objectTransform = new Float32Array(16);
    _angle = 0.0;
    _transformGraph = new TransformGraph();
    _transformNodes = new List<TransformGraphNode>();
    _transformNodes.add(_transformGraph.createNode());
    _transformNodes.add(_transformGraph.createNode());
    _transformNodes.add(_transformGraph.createNode());
    _transformNodes.add(_transformGraph.createNode());
    _transformGraph.reparent(_transformNodes[3], _transformNodes[2]);
    _transformGraph.reparent(_transformNodes[2], _transformNodes[1]);
    _transformGraph.reparent(_transformNodes[1], _transformNodes[0]);
    _transformGraph.updateGraph();
    _configUI = new ConfigUI();
    _configUI.addItem({
      'name': 'demo.postprocess',
      'widget': 'dropdown',
      'settings': {
        'values': ['blit','blur']
      }
    });
    _configUI.build();
  }

  /*
   * fix loading of input layout
   */
  Future<JavelinDemoStatus> startup() {
    Future<JavelinDemoStatus> base = super.startup();
    Completer<JavelinDemoStatus> complete = new Completer<JavelinDemoStatus>();
    base.then((value) {
      // Once the base is done, we load our resources
      renderConfigResource = resourceManager.registerResource('/renderer/basic.rc');
      cubeMeshResource = resourceManager.registerResource('/meshes/UnitCylinder.mesh');
      cubeVertexShaderResource = resourceManager.registerResource('/shaders/simple_texture.vs');
      cubeFragmentShaderResource = resourceManager.registerResource('/shaders/simple_texture.fs');
      cubeTextureResource = resourceManager.registerResource('/textures/WoodPlank.jpg');
      cubeVertexShader = device.createVertexShader('Cube Vertex Shader');
      cubeFragmentShader = device.createFragmentShader('Cube Fragment Shader');
      sampler = device.createSamplerState('Cube Texture Sampler');
      rs = device.createRasterizerState('Cube Rasterizer State');
      rs.cullEnabled = true;
      rs.cullMode = RasterizerState.CullBack;
      rs.cullFrontFace = RasterizerState.FrontCCW;

      texture = device.createTexture2D('Cube Texture');
      cubeMesh = device.createSingleArrayIndexedMesh('Cube Mesh');
      cubeProgram = device.createShaderProgram('Cube Program');
      il = device.createInputLayout('Cube Input Layout');
      ds = device.getDeviceChild('DepthState.TestWrite');
      il.shaderProgram = cubeProgram;
      il.mesh = cubeMesh;
      resourceManager.addEventCallback(cubeMeshResource, ResourceEvents.TypeUpdate, (type, resource) {
        MeshResource cube = resource;
        cubeMesh.attributes.clear();
        cubeMesh.attributes['vPosition'] = new SpectreMeshAttribute(
            'vPosition',
            'float',
            3,
            cube.meshData['meshes'][0]['attributes']['POSITION']['offset'],
            cube.meshData['meshes'][0]['attributes']['POSITION']['stride'],
            false);
        cubeMesh.attributes['vTexCoord'] = new SpectreMeshAttribute(
            'vTexCoord',
            'float',
            2,
            cube.meshData['meshes'][0]['attributes']['TEXCOORD0']['offset'],
            cube.meshData['meshes'][0]['attributes']['TEXCOORD0']['stride'],
            false);
        cubeMesh.numIndices = cube.numIndices;
        il.mesh = cubeMesh;
        cubeMesh.vertexArray.uploadData(cube.vertexArray,
                                        SpectreBuffer.UsageStatic);
        cubeMesh.indexArray.uploadData(cube.indexArray,
                                       SpectreBuffer.UsageStatic);
      });

      resourceManager.addEventCallback(cubeTextureResource, ResourceEvents.TypeUpdate, (type, resource) {
        texture.uploadElement(cubeTextureResource.image);
        texture.generateMipmap();
      });

      resourceManager.addEventCallback(cubeVertexShaderResource, ResourceEvents.TypeUpdate, (type, resource) {
        cubeVertexShader.source = cubeVertexShaderResource.source;
        assert(cubeVertexShader.compiled == true);
        cubeProgram.vertexShader = cubeVertexShader;
        cubeProgram.link();
        il.shaderProgram = cubeProgram;
      });

      resourceManager.addEventCallback(cubeFragmentShaderResource, ResourceEvents.TypeUpdate, (type, resource) {
        cubeFragmentShader.source = cubeFragmentShaderResource.source;
        assert(cubeFragmentShader.compiled == true);
        cubeProgram.fragmentShader = cubeFragmentShader;
        cubeProgram.link();
        il.shaderProgram = cubeProgram;
      });

      resourceManager.loadResource(renderConfigResource).then((_dd) {
        RenderConfigResource rcr = renderConfigResource;
        renderConfig.load(rcr.renderConfig);
        resourceManager.loadResource(cubeVertexShaderResource);
        resourceManager.loadResource(cubeFragmentShaderResource);
        resourceManager.loadResource(cubeMeshResource);
        resourceManager.loadResource(cubeTextureResource);

        complete.complete(new JavelinDemoStatus(JavelinDemoStatus.DemoStatusOKAY, ''));
      });
    });
    return complete.future;
  }

  Future<JavelinDemoStatus> shutdown() {
    resourceManager.batchDeregister([cubeMeshResource,
                                     cubeVertexShaderResource,
                                     cubeFragmentShaderResource,
                                     cubeTextureResource]);
    device.batchDeleteDeviceChildren([il,
                                      rs,
                                      sampler,
                                      texture,
                                      cubeProgram,
                                      cubeMesh,
                                      cubeVertexShader,
                                      cubeFragmentShader]);
    Future<JavelinDemoStatus> base = super.shutdown();
    return base;
  }

  void drawCube(mat4 T) {
    mat4 pm = camera.projectionMatrix;
    mat4 la = camera.lookAtMatrix;
    pm.multiply(la);
    pm.copyIntoArray(cameraTransform);
    T.copyIntoArray(objectTransform);
    device.context.setPrimitiveTopology(
        GraphicsContext.PrimitiveTopologyTriangles);
    device.context.setRasterizerState(rs);
    device.context.setDepthState(ds);
    device.context.setShaderProgram(cubeProgram);
    device.context.setConstant('objectTransform', objectTransform);
    device.context.setConstant('cameraTransform', cameraTransform);
    device.context.setTextures(0, [texture]);
    device.context.setSamplers(0, [sampler]);
    device.context.setInputLayout(il);
    device.context.setIndexedMesh(cubeMesh);
    device.context.drawIndexedMesh(cubeMesh);
  }

  Element makeDemoUI() {
    return _configUI.root;
  }

  void update(num time, num dt) {
    super.update(time, dt);
    _angle += dt * 3.14159;
    drawGrid(20);
    num h = sin(_angle);
    _transformGraph.setLocalMatrix(_transformNodes[2], new mat4.scaleRaw(1.0, 1.0, 1.0));
    _transformGraph.setLocalMatrix(_transformNodes[0], new mat4.translationRaw(h, 0.0, 1-h));
    _transformGraph.setLocalMatrix(_transformNodes[1], new mat4.rotationZ(_angle));
    _transformGraph.updateWorldMatrices();
    renderConfig.setupLayer('forward');
    device.context.clearDepthBuffer(1.0);
    device.context.clearColorBuffer(0.0, 0.0, 0.0, 1.0);
    drawCube(_transformGraph.refWorldMatrix(_transformNodes[3]));
    {
      aabb3 aabb = new aabb3.minmax(new vec3.raw(-0.5, -0.5, -0.5), new vec3(0.5, 0.5, 0.5));
      aabb3 out = new aabb3();
      aabb.transformed(_transformGraph.refWorldMatrix(_transformNodes[3]), out);
      debugDrawManager.addAABB(out.min, out.max, new vec4(1.0, 1.0, 1.0, 1.0));
    }
    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
    renderConfig.getBuffer('colorbuffer').generateMipmap();
    String postpass = JavelinConfigStorage.get('demo.postprocess');
    SpectrePost.pass(postpass, renderConfig.getLayer('final'), {
      'textures': [renderConfig.getBuffer('colorbuffer')],
      'samplers': [sampler]
    });
    renderConfig.setupLayer('final');
  }
}
