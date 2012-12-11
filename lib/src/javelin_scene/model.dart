part of javelin_scene;

class Model extends SceneChild {
  MaterialInstance _materialInstance;
  Mesh _mesh;
  InputLayout _inputLayoutHandle;
  TransformGraphNode transformHandle;
  TransformController controller;

  Model(String name, Scene scene) : super(name, scene) {
    transformHandle = scene.transformGraph.createNode();
    print('Spawned $name');
  }

  void delete() {
    scene.device.deleteDeviceChild(_inputLayoutHandle);
  }

  void update(MaterialInstance materialInstance, Mesh mesh, List layout) {
    _materialInstance = materialInstance;
    _mesh = mesh;
    if (_inputLayoutHandle == null) {
      _inputLayoutHandle = scene.device.createInputLayout('$name.il', {});
    }
    List<InputElementDescription> descriptions = new List<InputElementDescription>();
    layout.forEach((e) {
      InputLayoutDescription ild = new InputLayoutDescription(e['name'], 0, e['type']);
      InputElementDescription ied = InputLayoutHelper.inputElementDescriptionFromAttributes(ild, _mesh.attributes);
      descriptions.add(ied);
    });

    scene.device.configureDeviceChild(_inputLayoutHandle, {
      'shaderProgram': _materialInstance.material.shaderProgramHandle,
      'elements': descriptions
    });
  }

  void draw(Camera camera, Map globalUniforms) {
    scene.device.context.setInputLayout(_inputLayoutHandle);
    _mesh.preDraw();
    _materialInstance.preDraw();
    globalUniforms.forEach((k,v) {
      scene.device.context.setConstant(k, v);
    });
    Float32Array objectTransformArray = scene.transformGraph.refWorldMatrixArray(transformHandle);
    scene.device.context.setConstant('objectTransform', objectTransformArray);
    _mesh.draw();
  }
}
