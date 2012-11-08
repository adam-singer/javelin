part of javelin_scene;

class MaterialInstance extends SceneChild {
  Material material;
  int blendStateHandle;
  int depthStateHandle;
  int rasterizerStateHandle;
  Map uniforms;

  List<int> textures;
  List<int> samplers;
  Map<String, String> textureNameToResourceName;
  Map<String, int> textureNameToHandle;
  Map<String, int> samplerNameToHandle;

  MaterialInstance(String name, this.material, Scene scene) : super(name, scene) {
    blendStateHandle = scene.device.createBlendState('$name.bs', {});
    depthStateHandle = scene.device.createDepthState('$name.ds', {});
    rasterizerStateHandle = scene.device.createRasterizerState('$name.rs', {});
    textureNameToHandle = new Map<String, int>();
    samplerNameToHandle = new Map<String, int>();
    textureNameToResourceName = new Map<String, String>();
  }


  void delete() {
    scene.device.deleteDeviceChild(blendStateHandle);
    scene.device.deleteDeviceChild(depthStateHandle);
    scene.device.deleteDeviceChild(rasterizerStateHandle);
  }

  Map copyMap(Map i) {
    Map o = new Map();
    i.forEach((k,v) {
      o[k] = v;
    });
    return o;
  }

  void updateTextureTable(Map entity) {
    Material.updateTextureTable(scene, textureNameToResourceName, entity['textures'], textureNameToHandle);
    Material.updateSamplerTable(scene, name, entity['textures'], entity['samplers'], samplerNameToHandle);
  }

  void load(Map entity) {
    var o;
    var bs;
    var ds;
    var rs;

    o = material.entity['blend'];
    if (o != null) {
      bs = o;
    }
    o = entity['blend'];
    if (o != null) {
      bs = o;
    }

    o = material.entity['depth'];
    if (o != null) {
      ds = o;
    }
    o = entity['depth'];
    if (o != null) {
      ds = o;
    }

    o = material.entity['rasterizer'];
    if (o != null) {
      rs = o;
    }
    o = entity['rasterizer'];
    if (o != null) {
      rs = o;
    }

    if (bs != null) {
      scene.device.configureDeviceChild(blendStateHandle, bs);
    }

    if (ds != null) {
      scene.device.configureDeviceChild(depthStateHandle, ds);
    }

    if (rs != null) {
      scene.device.configureDeviceChild(rasterizerStateHandle, rs);
    }

    updateTextureTable(material.entity);
    updateTextureTable(entity);
    textures = Material.buildTextureHandleList(material.textureNameToUnit, textureNameToHandle);
    samplers = Material.buildTextureHandleList(material.textureNameToUnit, samplerNameToHandle);
  }

  void preDraw() {
    material.preDraw();
    scene.device.context.setTextures(0, textures);
    scene.device.context.setSamplers(0, samplers);
    scene.device.context.setBlendState(blendStateHandle);
    scene.device.context.setDepthState(depthStateHandle);
    scene.device.context.setRasterizerState(rasterizerStateHandle);
  }
}
