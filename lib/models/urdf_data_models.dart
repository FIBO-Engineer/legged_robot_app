import 'urdf_joint.dart';

class Vector3D {
  double x, y, z;
  Vector3D(this.x, this.y, this.z);

  @override
  String toString() => '($x, $y, $z)';
}

class Transform3D {
  Vector3D translation;
  Vector3D rotation;
  Transform3D(this.translation, this.rotation);
}

class GeometryData {
  String meshFile = '';
}

class VisualData {
  Transform3D origin = Transform3D(Vector3D(0, 0, 0), Vector3D(0, 0, 0));
  GeometryData geometry = GeometryData();
}

class URDFLinkData {
  String name;
  VisualData? visual;

  URDFLinkData(this.name);
}

class RobotData {
  List<URDFLinkData> links = [];
  List<URDFJoint> joints = [];
}
