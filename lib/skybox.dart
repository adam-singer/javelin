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

library skybox;
import 'dart:html';
import 'package:vector_math/vector_math_browser.dart';
import 'package:spectre/spectre.dart';

class Skybox {
  DepthState _depth;
  BlendState _blend;
  RasterizerState _rasterizer;
  SamplerState _sampler;
  InputLayout _inputLayout;

  static final String _depthStateName = 'Skybox.Depth State';
  static final String _blendStateName = 'Skybox.Blend State';
  static final String _rasterizerStateName = 'Skybox.Rasterizer State';
  static final String _vertexBufferName = 'Skybox.Mesh';
  static final String _skyboxTexture1Name = 'Skybox.Texture1';
  static final String _skyboxTexture2Name = 'Skybox.Texture2';
  static final String _skyboxSamplerName = 'Skybox.Sampler';
  static final String _inputLayoutName = 'Skybox.InputLayout';

  List<DeviceChild> _deviceHandles;

  static final int _skyboxVertexResourceHandleIndex = 0;

  static final String _skyboxVertexResourceName = 'SkyBoxVBO';

  List<ResourceBase> _resourceHandles;

  SingleArrayMesh mesh;

  GraphicsDevice device;
  ResourceManager resourceManager;

  Float32Array _lookatMatrix;
  Float32Array _blendT;

  Float32ArrayResource skyboxVertexResource;
  Texture2D skyboxTexture1Handle;
  Texture2D skyboxTexture2Handle;
  ShaderProgram shaderProgramHandle;
  Skybox(this.device, this.resourceManager, this.shaderProgramHandle, this.skyboxTexture1Handle, this.skyboxTexture2Handle) {
    _deviceHandles = new List<DeviceChild>();
    _resourceHandles = new List<ResourceBase>();
    skyboxVertexResource = new Float32ArrayResource(_skyboxVertexResourceName, resourceManager);
    _lookatMatrix = new Float32Array(16);
    _blendT = new Float32Array(4);
  }

  void init() {
    _depth = device.createDepthState(_depthStateName);
    _depth.depthTestEnabled = false;
    _depth.depthWriteEnabled = false;
    _blend = device.createBlendState(_blendStateName);
    _rasterizer = device.createRasterizerState(_rasterizerStateName);
    _rasterizer.cullEnabled = false;
    _sampler = device.createSamplerState(_skyboxSamplerName);
    _inputLayout = device.createInputLayout(_inputLayoutName);

    mesh = device.createSingleArrayMesh(_vertexBufferName);
    mesh.attributes['vPosition'] = new SpectreMeshAttribute('vPosition',
                                                            'float',
                                                            3,
                                                            0,
                                                            20,
                                                            false);
    mesh.attributes['vTexCoord'] = new SpectreMeshAttribute('vTexCoord',
                                                            'float',
                                                            2,
                                                            12,
                                                            20,
                                                            false);

    _inputLayout.mesh = mesh;
    _inputLayout.shaderProgram = shaderProgramHandle;
    _resourceHandles.add(skyboxVertexResource);

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

    mesh.vertexArray.uploadData(vb, SpectreBuffer.UsageStatic);
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
    device.context.setDepthState(_depth);
    device.context.setBlendState(_blend);
    device.context.setRasterizerState(_rasterizer);
    device.context.setShaderProgram(shaderProgramHandle);
    device.context.setTextures(0, [skyboxTexture1Handle, skyboxTexture2Handle]);
    device.context.setSamplers(0, [_sampler, _sampler]);
    device.context.setVertexBuffers(0, [mesh.vertexArray]);
    device.context.setInputLayout(_inputLayout);
    device.context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyTriangles);
    device.context.setConstant('sampler1', 0);
    device.context.setConstant('sampler2', 1);
    device.context.setConstant('t', blendT);
    device.context.setConstant('cameraTransform', _lookatMatrix);
    device.context.draw(36, 0);
  }
}
