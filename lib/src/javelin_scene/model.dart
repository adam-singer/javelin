part of javelin_scene;

class Model extends SceneChild {
  MaterialInstance _materialInstance;
  Mesh _mesh;
  InputLayout _inputLayout;
  TransformGraphNode transformHandle;
  TransformController controller;

  Model(String name, Scene scene) : super(name, scene) {
    transformHandle = scene.transformGraph.createNode();
    print('Spawned $name');
  }

  void delete() {
    scene.device.deleteDeviceChild(_inputLayout);
  }

  void update(MaterialInstance materialInstance, Mesh mesh, List layout) {
    _materialInstance = materialInstance;
    _mesh = mesh;
    if (_inputLayout == null) {
      _inputLayout = scene.device.createInputLayout('$name.il');
    }
    _inputLayout.shaderProgram = _materialInstance.material.shaderProgramHandle;
    _inputLayout.mesh = mesh.indexedMesh;
  }

  void draw(Camera camera, Map globalUniforms) {
    scene.device.context.setInputLayout(_inputLayout);
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
