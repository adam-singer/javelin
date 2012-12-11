part of javelin_scene;

class Material extends SceneChild {
  VertexShader vertexShaderHandle;
  FragmentShader fragmentShaderHandle;
  ShaderProgram shaderProgramHandle;
  Map<String, int> textureNameToUnit;
  Map entity;

  List<Map> meshinputs;
  Map uniformset;
  Material(String name, Scene scene) : super(name, scene) {
    vertexShaderHandle = null;
    fragmentShaderHandle = null;
    shaderProgramHandle = null;
    textureNameToUnit = new Map<String, int>();
  }

  void delete() {
    scene.device.deleteDeviceChild(vertexShaderHandle);
    scene.device.deleteDeviceChild(fragmentShaderHandle);
    scene.device.deleteDeviceChild(shaderProgramHandle);
  }

  void processUniforms() {
    textureNameToUnit.clear();
    int textureUnitIndex = 0;
    shaderProgramHandle.forEachSampler((sampler) {
      if (sampler.type == 'sampler2D') {
        textureNameToUnit[sampler.name] = textureUnitIndex++;
      }
    });
  }

  static List<SamplerState> buildSamplerStateHandleList(Map nameToUnit, Map nameToHandle) {
    if (nameToUnit == null) {
      print('null nameToUnit');
    }
    List<SamplerState> out = new List<SamplerState>(nameToUnit.length);
    nameToHandle.forEach((k, v) {
      int slot = nameToUnit[k];
      if (slot == null) {
        return;
      }
      SamplerState handle = v;
      out[slot] = handle;
    });
    return out;
  }

  static List<DeviceChild> buildTextureHandleList(Map nameToUnit, Map nameToHandle) {
    if (nameToUnit == null) {
      print('null nameToUnit');
    }
    List<Texture> out = new List<Texture>(nameToUnit.length);
    nameToHandle.forEach((k, v) {
      int slot = nameToUnit[k];
      if (slot == null) {
        return;
      }
      Texture handle = v;
      out[slot] = handle;
    });
    return out;
  }

  static void updateTextureTable(Scene scene, Map textureNameToResourceName, Map textures, Map textureNameToHandle) {
    if (textures == null) {
      return;
    }
    textures.forEach((textureName, resourceName) {
      if (textureNameToResourceName[textureName] == resourceName) {
        // Already up to date
        return;
      }
      // New or changed texture resource
      textureNameToResourceName[textureName] = resourceName;
      Texture2D resourceTextureHandle = scene.device.getDeviceChild(resourceName);
      if (resourceTextureHandle != null) {
        // Texture already exists, update table
        textureNameToHandle[textureName] = resourceTextureHandle;
        return;
      }
    });
  }

  static void updateSamplerTable(Scene scene, String prefix, Map textures, Map samplers, Map samplerNameToHandle) {
    if (textures == null || samplers == null) {
      return;
    }
    textures.forEach((textureName, _) {
      SamplerState handle = samplerNameToHandle[textureName];
      if (handle == null) {
        handle = scene.device.createSamplerState('$prefix.$textureName.sampler', {});
        samplerNameToHandle[textureName] = handle;
      }
      Map sampler = samplers[textureName];
      if (sampler != null) {
        scene.device.configureDeviceChild(handle, sampler);
      }
    });
  }

  void load(Map o) {
    entity = o;
    uniformset = o['uniformset'];
    meshinputs = o['meshinputs'];
    String shaderName = o['shader'];
    ShaderProgramResource spr = scene.resourceManager.getResource(shaderName);
    if (spr == null) {
      spectreLog.Error('Could not load $name');
      return;
    }
    if (vertexShaderHandle == null) {
      vertexShaderHandle = scene.device.createVertexShader('$shaderName.vs', {});
    }
    if (fragmentShaderHandle == null) {
      fragmentShaderHandle = scene.device.createFragmentShader('$shaderName.fs', {});
    }
    if (shaderProgramHandle == null) {
      shaderProgramHandle = scene.device.createShaderProgram('$shaderName.sp', {});
    }

    bool relink = false;
    VertexShader vs = vertexShaderHandle;
    if (vs.source != spr.vertexShaderSource) {
      vs.source = spr.vertexShaderSource;
      vs.compile();
      relink = true;
    }

    FragmentShader fs = fragmentShaderHandle;
    if (fs.source != spr.fragmentShaderSource) {
      fs.source = spr.fragmentShaderSource;
      fs.compile();
      relink = true;
    }

    ShaderProgram sp = shaderProgramHandle;
    if (!sp.linked || relink) {
      scene.device.configureDeviceChild(shaderProgramHandle, {
        'VertexProgram': vertexShaderHandle,
        'FragmentProgram': fragmentShaderHandle,
      });
      processUniforms();
    }
  }

  void preDraw() {
    scene.device.context.setShaderProgram(shaderProgramHandle);
    if (uniformset != null) {
      uniformset.forEach((name, value) {
        scene.device.context.setConstant(name, value);
      });
    }
  }
}