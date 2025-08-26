import 'package:flutter/services.dart';
import 'package:three_js/three_js.dart' as three;
import '../services/talker_service.dart';
import 'urdf_data_models.dart';
import 'urdf_link.dart';
import 'urdf_joint.dart';
import 'urdf_parser.dart';

class URDFRobot {
  late three.Group rootGroup;
  List<URDFLink> links = [];
  List<URDFJoint> joints = [];
  Map<String, double> jointValues = {};

  URDFRobot() {
    rootGroup = three.Group();
    rootGroup.name = 'URDFRobot';
  }

  Future<void> loadFromURDF(String urdfPath) async {
    try {
      // Load URDF content
      final urdfContent = await rootBundle.loadString(urdfPath);
      talker.info('URDF loaded: ${urdfContent.length} characters');

      // Parse URDF
      final parser = URDFParser();
      final robotData = parser.parseURDF(urdfContent);

      // Create phantom links for missing parents
      final Set<String> allParents = robotData.joints.map((j) => j.parent).toSet();
      final Set<String> existingLinks = robotData.links.map((l) => l.name).toSet();

      // Add phantom links
      for (final parentName in allParents) {
        if (!existingLinks.contains(parentName) && parentName != 'world') {
          // Create phantom link without mesh
          final phantomLinkData = URDFLinkData(parentName);
          final phantomLink = URDFLink(phantomLinkData);
          links.add(phantomLink);
          rootGroup.add(phantomLink.group);
          talker.info('Created phantom link: $parentName');
        }
      }

      // Load links with meshes
      for (final linkData in robotData.links) {
        if (linkData.visual != null && linkData.visual!.geometry.meshFile.isNotEmpty) {
          try {
            final link = URDFLink(linkData);
            await link.loadMesh();
            links.add(link);
            rootGroup.add(link.group);
            talker.info('✓ Loaded link: ${linkData.name}');
          } catch (e) {
            talker.error('✗ Failed to load link ${linkData.name}: $e');
          }
        }
      }

      // Store joints for animation
      joints = robotData.joints;

      // Initialize joint values
      for (final joint in joints) {
        jointValues[joint.name] = 0.0;
      }

      // Apply joint transforms
      _applyJointTransforms();
    } catch (e) {
      talker.error('Error loading URDF: $e');
      rethrow;
    }
  }

  void _applyJointTransforms() {
    // Create map for faster link lookup
    final Map<String, URDFLink> linkMap = {};
    for (final link in links) {
      linkMap[link.data.name] = link;
    }

    // Apply transforms for all joints (except world joints)
    for (final joint in joints) {
      if (joint.parent == 'world') continue;

      final parentLink = linkMap[joint.parent];
      final childLink = linkMap[joint.child];

      if (parentLink != null && childLink != null) {
        // Remove child from root first
        rootGroup.remove(childLink.group);

        // Add child as child of parent
        parentLink.group.add(childLink.group);

        // Use joint origin transform
        final transform = joint.origin;
        childLink.group.position.setValues(transform.translation.x, transform.translation.y, transform.translation.z);

        // Apply initial rotation + joint value
        _updateJointRotation(joint, childLink);
      }
    }
  }

  void _updateJointRotation(URDFJoint joint, URDFLink childLink) {
    final jointValue = jointValues[joint.name] ?? 0.0;
    final baseRotation = joint.origin.rotation;
    final axis = joint.axis;

    // Calculate rotation based on joint axis and value
    final rotationX = baseRotation.x + (axis.x * jointValue);
    final rotationY = baseRotation.y + (axis.y * jointValue);
    final rotationZ = baseRotation.z + (axis.z * jointValue);

    childLink.group.rotation.setFromVector3(three.Vector3(rotationX, rotationY, rotationZ));
  }

  List<URDFJoint> getControllableJoints() {
    // Filter out fixed joints and world joints, show only revolute joints
    return joints
        .where(
          (joint) =>
              joint.parent != 'world' && joint.type == 'revolute' && joint.name.contains(RegExp(r'(shoulder|elbow|wrist)')), //|waisthip|knee|ankle|
        )
        .toList();
  }

  double getJointValue(String jointName) {
    return jointValues[jointName] ?? 0.0;
  }

  void setJointValue(String jointName, double value) {
    jointValues[jointName] = value;

    // Find the joint and update its rotation
    final joint = joints.firstWhere((j) => j.name == jointName);
    final childLink = _findLinkByName(joint.child);

    if (childLink != null) {
      _updateJointRotation(joint, childLink);
    }
  }

  void resetJoints() {
    for (final jointName in jointValues.keys) {
      setJointValue(jointName, 0.0);
    }
  }

  URDFLink? _findLinkByName(String name) {
    for (final link in links) {
      if (link.data.name == name) return link;
    }
    return null;
  }

  void update(double dt) {
    // Animation logic can be added here
  }
}
