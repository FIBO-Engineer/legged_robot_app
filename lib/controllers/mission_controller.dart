import 'package:get/get.dart';

class MissionController extends GetxController {
  final RxList<Map<String, dynamic>> tasks =
      <Map<String, dynamic>>[
        {
          "id": "FPG_3FL_AirQuality_SingleInsert_AM",
          "task": "root",
          "status": "running",
          "isSelected": false,
        },
        {
          "id": "FPG_3FL_SimpleTest",
          "task": "root",
          "status": "running",
          "isSelected": false,
        },
        {
          "id": "MainTree",
          "task": "root",
          "status": "idle",
          "isSelected": false,
        },
      ].obs;

  final selectedTaskId = ''.obs;
  final isPlayed = false.obs;

  void selectTask(String taskId) {
    final idx = tasks.indexWhere((t) => t['id'] == taskId);
    if (idx < 0) return;

    final currentlySelected = tasks[idx]['isSelected'] == true;
    tasks[idx]['isSelected'] = !currentlySelected;

    if (tasks[idx]['isSelected'] == true) {
      for (int i = 0; i < tasks.length; i++) {
        if (i != idx) tasks[i]['isSelected'] = false;
      }
      selectedTaskId.value = taskId;
    } else {
      selectedTaskId.value = '';
    }
    tasks.refresh();
  }

  Map<String, dynamic>? get selectedTask {
    if (selectedTaskId.value.isEmpty) return null;
    return tasks.firstWhereOrNull((t) => t['id'] == selectedTaskId.value);
  }

  void togglePlay() => isPlayed.toggle();

  void addTask({
    required String id,
    required String task,
    required String status,
  }) {
    tasks.add({"id": id, "task": task, "status": status, "isSelected": false});
  }

  void editTask(String id, {String? task, String? status}) {
    final idx = tasks.indexWhere((t) => t['id'] == id);
    if (idx < 0) return;
    if (task != null) tasks[idx]['task'] = task;
    if (status != null) tasks[idx]['status'] = status;
    tasks.refresh();
  }

  void deleteTask(String id) {
    tasks.removeWhere((t) => t['id'] == id);
    if (selectedTaskId.value == id) selectedTaskId.value = '';
  }
}
