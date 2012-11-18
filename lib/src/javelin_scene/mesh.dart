part of javelin_scene;

class Mesh extends SceneChild {
  IndexedMesh indexedMesh;
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
      indexedMesh = scene.device.createIndexedMesh(name, {
        'UpdateFromMeshResource': {
          'resourceManager': scene.resourceManager,
          'meshResourceHandle': mr
        }
      });
    } else {
      scene.device.configureDeviceChild(indexedMesh, {
        'UpdateFromMeshResource': {
          'resourceManager': scene.resourceManager,
          'meshResourceHandle': mr
        }
      });
    }
    attributes = mr.meshData['meshes'][0]['attributes'];
  }

  void preDraw() {
    IndexedMesh im = indexedMesh;
    scene.device.context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyTriangles);
    scene.device.context.setIndexBuffer(im.indexArray);
    scene.device.context.setVertexBuffers(0, [im.vertexArray]);
  }

  void draw() {
    IndexedMesh im = indexedMesh;
    scene.device.context.drawIndexed(im.numIndices, im.indexOffset);
  }
}
