
import 'urdf_data_models.dart';

class JointLimits {
  double lower;
  double upper;
  JointLimits(this.lower, this.upper);
}

class URDFJoint {
  String name = '';
  String type = '';
  String parent = '';
  String child = '';
  Transform3D origin = Transform3D(Vector3D(0, 0, 0), Vector3D(0, 0, 0));
  Vector3D axis = Vector3D(0, 0, 1); // Default Z-axis
  JointLimits? limits;
}
