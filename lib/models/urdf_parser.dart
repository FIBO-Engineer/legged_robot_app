import 'dart:math' as math;
import '../services/talker_service.dart';
import 'urdf_data_models.dart';
import 'urdf_joint.dart';

class URDFParser {
  RobotData parseURDF(String urdfContent) {
    final robotData = RobotData();

    // Parse links
    final linkMatches = RegExp(r'<link\s+name="([^"]+)".*?</link>', dotAll: true).allMatches(urdfContent);
    for (final match in linkMatches) {
      final linkContent = match.group(0)!;
      final linkName = match.group(1)!;

      final linkData = _parseLink(linkName, linkContent);
      robotData.links.add(linkData);
    }

    // Parse joints
    final jointMatches = RegExp(r'<joint\s+name="([^"]+)".*?</joint>', dotAll: true).allMatches(urdfContent);
    for (final match in jointMatches) {
      final jointContent = match.group(0)!;
      final jointName = match.group(1)!;

      final jointData = _parseJoint(jointName, jointContent);
      robotData.joints.add(jointData);
    }

    talker.info('Parsed ${robotData.links.length} links and ${robotData.joints.length} joints');
    return robotData;
  }

  URDFLinkData _parseLink(String name, String linkContent) {
    final linkData = URDFLinkData(name);

    // Parse visual block
    final visualMatch = RegExp(r'<visual.*?</visual>', dotAll: true).firstMatch(linkContent);
    if (visualMatch != null) {
      linkData.visual = _parseVisual(visualMatch.group(0)!);
    }

    return linkData;
  }

  VisualData _parseVisual(String visualContent) {
    final visual = VisualData();

    // Parse origin
    final originMatch = RegExp(r'<origin\s+xyz="([^"]*)"(?:\s+rpy="([^"]*)")?').firstMatch(visualContent);
    if (originMatch != null) {
      final xyz = originMatch.group(1)?.split(' ').map((s) => double.tryParse(s.trim()) ?? 0.0).toList() ?? [0.0, 0.0, 0.0];
      final rpy = originMatch.group(2)?.split(' ').map((s) => double.tryParse(s.trim()) ?? 0.0).toList() ?? [0.0, 0.0, 0.0];

      visual.origin = Transform3D(
        Vector3D(xyz.length >= 3 ? xyz[0] : 0, xyz.length >= 3 ? xyz[1] : 0, xyz.length >= 3 ? xyz[2] : 0),
        Vector3D(rpy.length >= 3 ? rpy[0] : 0, rpy.length >= 3 ? rpy[1] : 0, rpy.length >= 3 ? rpy[2] : 0),
      );
    }

    // Parse geometry/mesh
    final meshMatch = RegExp(r'<mesh\s+filename="([^"]+)"').firstMatch(visualContent);
    if (meshMatch != null) {
      final filename = meshMatch.group(1)!;
      visual.geometry.meshFile = filename.split('/').last;
    }

    return visual;
  }

  URDFJoint _parseJoint(String name, String jointContent) {
    final joint = URDFJoint();
    joint.name = name;

    // Parse joint type
    final typeMatch = RegExp(r'<joint\s+name="[^"]+"\s+type="([^"]+)"').firstMatch(jointContent);
    if (typeMatch != null) {
      joint.type = typeMatch.group(1)!;
    }

    // Parse parent
    final parentMatch = RegExp(r'<parent\s+link="([^"]+)"').firstMatch(jointContent);
    if (parentMatch != null) {
      joint.parent = parentMatch.group(1)!;
    }

    // Parse child
    final childMatch = RegExp(r'<child\s+link="([^"]+)"').firstMatch(jointContent);
    if (childMatch != null) {
      joint.child = childMatch.group(1)!;
    }

    // Parse origin
    final originMatch = RegExp(r'<origin\s+xyz="([^"]*)"(?:\s+rpy="([^"]*)")?').firstMatch(jointContent);
    if (originMatch != null) {
      final xyz = originMatch.group(1)?.split(' ').map((s) => double.tryParse(s.trim()) ?? 0.0).toList() ?? [0.0, 0.0, 0.0];
      final rpy = originMatch.group(2)?.split(' ').map((s) => double.tryParse(s.trim()) ?? 0.0).toList() ?? [0.0, 0.0, 0.0];

      joint.origin = Transform3D(
        Vector3D(xyz.length >= 3 ? xyz[0] : 0, xyz.length >= 3 ? xyz[1] : 0, xyz.length >= 3 ? xyz[2] : 0),
        Vector3D(rpy.length >= 3 ? rpy[0] : 0, rpy.length >= 3 ? rpy[1] : 0, rpy.length >= 3 ? rpy[2] : 0),
      );
    }

    // Parse axis
    final axisMatch = RegExp(r'<axis\s+xyz="([^"]+)"').firstMatch(jointContent);
    if (axisMatch != null) {
      final axisValues = axisMatch.group(1)!.split(' ').map((s) => double.tryParse(s.trim()) ?? 0.0).toList();
      if (axisValues.length >= 3) {
        joint.axis = Vector3D(axisValues[0], axisValues[1], axisValues[2]);
      }
    }

    // Parse limits
    final limitsMatch = RegExp(r'<limit\s+lower="([^"]+)"\s+upper="([^"]+)"').firstMatch(jointContent);
    if (limitsMatch != null) {
      final lower = double.tryParse(limitsMatch.group(1)!) ?? -math.pi;
      final upper = double.tryParse(limitsMatch.group(2)!) ?? math.pi;
      joint.limits = JointLimits(lower, upper);
    }

    return joint;
  }
}
