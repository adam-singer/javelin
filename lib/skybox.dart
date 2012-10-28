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

#library('skybox');
#import('dart:html');
#import('package:vector_math/vector_math_browser.dart');
#import('package:spectre/spectre.dart');

class Skybox {
  static final int _depthStateHandleIndex = 0;
  static final int _blendStateHandleIndex = 1;
  static final int _rasterizerStateHandleIndex = 2;
  static final int _vertexBufferHandleIndex = 3;
  static final int _skyboxSamplerHandleIndex = 4;
  static final int _inputLayoutHandleIndex = 5;

  static final String _depthStateName = 'Skybox.Depth State';
  static final String _blendStateName = 'Skybox.Blend State';
  static final String _rasterizerStateName = 'Skybox.Rasterizer State';
  static final String _vertexBufferName = 'Skybox.Vertex Buffer';
  static final String _skyboxTexture1Name = 'Skybox.Texture1';
  static final String _skyboxTexture2Name = 'Skybox.Texture2';
  static final String _skyboxSamplerName = 'Skybox.Sampler';
  static final String _inputLayoutName = 'Skybox.InputLayout';

  List<int> _deviceHandles;

  static final int _skyboxVertexResourceHandleIndex = 0;

  static final String _skyboxVertexResourceName = 'SkyBoxVBO';

  List<int> _resourceHandles;

  GraphicsDevice device;
  ResourceManager resourceManager;

  Float32Array _lookatMatrix;
  Float32Array _blendT;

  Float32ArrayResource skyboxVertexResource;
  int skyboxTexture1Handle;
  int skyboxTexture2Handle;
  int shaderProgramHandle;
  Skybox(this.device, this.resourceManager, this.shaderProgramHandle, this.skyboxTexture1Handle, this.skyboxTexture2Handle) {
    _deviceHandles = new List<int>();
    _resourceHandles = new List<int>();
    skyboxVertexResource = new Float32ArrayResource(_skyboxVertexResourceName, resourceManager);
    _lookatMatrix = new Float32Array(16);
    _blendT = new Float32Array(4);
  }

  void init() {
    _deviceHandles.add(device.createDepthState(_depthStateName, {'depthTestEnabled': false, 'depthWriteEnabled': false}));
    _deviceHandles.add(device.createBlendState(_blendStateName, {}));
    _deviceHandles.add(device.createRasterizerState(_rasterizerStateName, {'cullEnabled': false}));
    _deviceHandles.add(device.createVertexBuffer(_vertexBufferName, {}));
    _deviceHandles.add(device.createSamplerState(_skyboxSamplerName, {}));
    _deviceHandles.add(device.createInputLayout(_inputLayoutName, {}));

    //   InputElementDescription(this.name, this.format, this.elementStride, this.vertexBufferSlot, this.vertexBufferOffset);
    var elements = [new InputElementDescription('vPosition', GraphicsDevice.DeviceFormatFloat3, 20, 0, 0), new InputElementDescription('vTexCoord', GraphicsDevice.DeviceFormatFloat2, 20, 0, 12)];

    device.configureDeviceChild(_deviceHandles[_inputLayoutHandleIndex], {'elements': elements, 'shaderProgram': shaderProgramHandle});

    _resourceHandles.add(resourceManager.registerDynamicResource(skyboxVertexResource));

    buildVertexBuffer();
  }

  void buildVertexBuffer() {
    final int numFloatsPerVertex = 3 + 2; // 3 position + 2 texture coordinates
    final int numVertices = 6 * 6; // 6 verts per side, 6 sides
    final int numFloats = numVertices * numFloatsPerVertex;
    Float32Array vb = new Float32Array(numFloats);

    for (int i = 0; i < numFloats; i++) {
      vb[i] = 0.0;
    }

    num tcOriginX;
    num tcOriginY;
    num tcWidth = -0.25;
    num tcHeight = -0.3333;

    num scale = 500.0;

    int index = 0;
    tcOriginX = 0.25;
    tcOriginY = 0.667;
    // face 0
    {
      // tri 0
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY; // tc

      // tri 1
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY; // tc

      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY+tcHeight; // tc
    }

    tcOriginX = 0.5;
    // face 2
    {
      // tri 0
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY; // tc

      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

      // tri 1
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY; // tc

      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY; // tc
    }

    // face 1
    {
      // tri 0
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX-tcWidth; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX-tcWidth; // tc
      vb[index++] = tcOriginY; // tc

      // tri 1
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY; // tc

      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX-tcWidth; // tc
      vb[index++] = tcOriginY+tcHeight; // tc
    }

    tcOriginX = 1.0;
    // face 3
    {

      // tri 0
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

      // tri 1
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY; // tc
    }

    tcOriginX = 0.5;
    tcOriginY = 0.0;
    // face 4
    {
      // tri 1
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY-tcHeight; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY; // tc

      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY-tcHeight; // tc

      // tri 0
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY-tcHeight; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY; // tc
    }

    tcOriginX = 0.5;
    tcOriginY = 1.0;
    // face 4
    {

      // tri 0
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY; // tc

      // tri 1
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = tcOriginX; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

      vb[index++] = 1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY; // tc

      vb[index++] = -1.0 * scale; // vp
      vb[index++] = -1.0 * scale; // vp
      vb[index++] = 1.0 * scale; // vp
      vb[index++] = tcOriginX+tcWidth; // tc
      vb[index++] = tcOriginY+tcHeight; // tc

    }

    skyboxVertexResource.array = vb;

    device.context.updateBuffer(_deviceHandles[_vertexBufferHandleIndex], skyboxVertexResource.array);
  }

  void fini() {
    resourceManager.batchDeregister(_resourceHandles);
    device.batchDeleteDeviceChildren(_deviceHandles);
  }

  void draw(Camera camera, num blendT) {
    {
      mat4 T = camera.projectionMatrix;
      mat4 L = makeLookAt(new vec3.zero(), camera.frontDirection, new vec3.raw(0.0, 1.0, 0.0));
      T.multiply(L);
      T.copyIntoArray(_lookatMatrix);
    }
    device.context.setDepthState(_deviceHandles[_depthStateHandleIndex]);
    device.context.setBlendState(_deviceHandles[_blendStateHandleIndex]);
    device.context.setRasterizerState(_deviceHandles[_rasterizerStateHandleIndex]);
    device.context.setShaderProgram(shaderProgramHandle);
    device.context.setTextures(0, [skyboxTexture1Handle, skyboxTexture2Handle]);
    device.context.setSamplers(0, [_deviceHandles[_skyboxSamplerHandleIndex], _deviceHandles[_skyboxSamplerHandleIndex]]);
    device.context.setVertexBuffers(0, [_deviceHandles[_vertexBufferHandleIndex]]);
    device.context.setInputLayout(_deviceHandles[_inputLayoutHandleIndex]);
    device.context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyTriangles);
    device.context.setUniformInt('sampler1', 0);
    device.context.setUniformInt('sampler2', 1);
    device.context.setUniformNum('t', blendT);
    device.context.setUniformMatrix4('cameraTransform', _lookatMatrix);
    device.context.draw(36, 0);
  }
}
