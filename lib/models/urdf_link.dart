import 'package:three_js/three_js.dart' as three;
import '../services/talker_service.dart';
import 'urdf_data_models.dart';

class URDFLink {
  final URDFLinkData data;
  late three.Group group;
  three.Mesh? mesh;

  URDFLink(this.data) {
    group = three.Group();
    group.name = data.name;
  }

  Future<void> loadMesh() async {
    if (data.visual?.geometry.meshFile.isEmpty ?? true) return;

    try {
      final stlLoader = three.STLLoader();
      final meshPath =
          'assets/robot/g1/meshes/${data.visual!.geometry.meshFile}';

      final loadedMesh = await stlLoader.fromAsset(meshPath);
      if (loadedMesh != null) {
        final geometry = loadedMesh.geometry;

        // Create material
        final material = three.MeshLambertMaterial.fromMap({
          'color': _getLinkColor(),
          'transparent': false,
        });

        mesh = three.Mesh(geometry, material);
        mesh!.name = '${data.name}_mesh';

        // Apply visual origin transform
        if (data.visual != null) {
          final origin = data.visual!.origin;
          mesh!.position.setValues(
            origin.translation.x,
            origin.translation.y,
            origin.translation.z,
          );
          mesh!.rotation.setFromVector3(
            three.Vector3(
              origin.rotation.x,
              origin.rotation.y,
              origin.rotation.z,
            ),
          );
        }

        group.add(mesh!);
      }
    } catch (e) {
      talker.error('Failed to load mesh for ${data.name}: $e');
      rethrow;
    }
  }

  int _getLinkColor() {
    // Separate colors by part type
    final name = data.name.toLowerCase();

    if (name.contains('pelvis') || name.contains('torso')) {
      return 0xFF2D3541; // Blue for torso
    } else if (name.contains('leg') ||
        name.contains('hip') ||
        name.contains('knee') ||
        name.contains('ankle')) {
      return 0xFFADB3BC; // Green for legs
    } else if (name.contains('arm') ||
        name.contains('shoulder') ||
        name.contains('elbow') ||
        name.contains('wrist') ||
        name.contains('hand')) {
      return 0xFFADB3BC; // Orange for arms
    }
    //  else if (name.contains('head')) {
    //   return 0xF44336; // Red for head
    // }
    else {
      return 0xFFADB3BC; // Gray for other parts
    }
  }
}
