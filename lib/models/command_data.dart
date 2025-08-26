// ===========================================
// lib/models/command_data.dart
// ===========================================
class CommandData {
  final String op;
  final String service;
  final Map<String, dynamic> args;

  CommandData({required this.op, required this.service, required this.args});

  Map<String, dynamic> toJson() {
    return {'op': op, 'service': service, 'args': args};
  }
}
