part of javelin_scene;

class Mesh extends SceneChild {
  SingleArrayIndexedMesh indexedMesh;
  Map attributes;
  Mesh(String name, Scene scene) : super(name, scene) {
    indexedMesh = null;
  }

  void delete() {
    if (indexedMesh != null) {
      scene.device.deleteDeviceChild(indexedMesh);
    }
  }

  void load(Map o) {
    print('Mesh.load $name');
    MeshResource mr = scene.resourceManager.getResource(name);
    if (mr == null) {
      spectreLog.Error('Could not find $name');
      return;
    }
    if (indexedMesh == null) {
      indexedMesh = scene.device.createSingleArrayIndexedMesh(name);
    }
    indexedMesh.attributes.clear();
    indexedMesh.vertexArray.uploadData(mr.vertexArray,
                                       SpectreBuffer.UsageStatic);
    indexedMesh.indexArray.uploadData(mr.indexArray,
                                      SpectreBuffer.UsageStatic);
    mr.meshData['meshes'][0]['attributes'].forEach((name, attribute) {
      int numComponents = attribute['numElements'];
      int stride = attribute['stride'];
      int offset = attribute['offset'];
      indexedMesh.attributes[name] = new SpectreMeshAttribute(name,
                                                              'float',
                                                              numComponents,
                                                              offset,
                                                              stride,
                                                              false);
    });
  }

  void preDraw() {
    SingleArrayIndexedMesh im = indexedMesh;
    scene.device.context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyTriangles);
    scene.device.context.setIndexBuffer(im.indexArray);
    scene.device.context.setVertexBuffers(0, [im.vertexArray]);
  }

  void draw() {
    SingleArrayIndexedMesh im = indexedMesh;
    scene.device.context.drawIndexed(im.numIndices, 0);
  }
}
