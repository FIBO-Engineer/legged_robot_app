import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/controllers/mission_controller.dart';
import '../units/app_colors.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_widget.dart';
import '../widgets/dashed_painter.dart';

class MissionPage extends StatelessWidget {
  const MissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);

    if (screen.isDesktop || screen.isTablet) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildResponsiveNavBar(context),
            Expanded(child: MissionScreen()),
          ],
        ),
      );
    } else if (screen.isPortrait) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(child: MissionScreen()),
            buildResponsiveNavBar(context),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(child: MissionScreen()),
            buildResponsiveNavBar(context),
          ],
        ),
      );
    }
  }
}

//---------------------- Mission Content Responsive ---------------------//
class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final MissionController controller = Get.put(MissionController());

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusWidget(theme, controller),
              _controlWidgt(controller),
            ],
          ),
          const SizedBox(height: 12),
          _buildListView(controller, theme),
        ],
      ),
    );
  }

  Widget _statusWidget(ThemeData theme, MissionController controller) {
    return Obx(() {
      final selected = controller.selectedTask;
      final id = (selected?['id'] as String?)?.trim();
      final taskName = (selected?['task'] as String?)?.trim();
      final status = (selected?['status'] as String?)?.trim();

      final hasSelected = selected != null;
      final baseColor = hasSelected ? AppColors.primary : AppColors.grey;

      String textOrDash(String? s) => (s == null || s.isEmpty) ? '' : s;

      return Wrap(
        spacing: 28,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SectionStatus(
            icon: Icons.track_changes_rounded,
            label: 'Status : ',
            value: textOrDash(status),
            color: baseColor,
          ),
          SectionStatus(
            icon: Icons.local_police_outlined,
            label: ' ID : ',
            value: textOrDash(id),
            color: baseColor,
          ),
          SectionStatus(
            icon: Icons.move_down_rounded,
            label: ' Task : ',
            value: textOrDash(taskName),
            color: baseColor,
          ),
        ],
      );
    });
  }

  Widget _controlWidgt(MissionController controller) {
    return Row(
      children: [
        Obx(
          () => CustomButton(
            text: controller.isPlayed.value ? "Pause" : "Play",
            icon:
                controller.isPlayed.value
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
            foregroundColor:
                controller.isPlayed.value ? AppColors.orange : AppColors.green,
            onPressed: controller.togglePlay,
          ),
        ),
        const SizedBox(width: 16),
        CustomButton(
          text: "Stop",
          icon: Icons.stop_circle_rounded,
          foregroundColor: AppColors.red,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _newMission(ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () { showCustomDialog(
                        title: 'New',
                        message: 'Are you sure you want to add new mission?',
                        color: AppColors.primary,
                        icon: Icons.add_rounded,
                        onConfirm: () {},
                      );},
      child: CustomPaint(
        foregroundPainter: DashedPainter(radius: 12, color: AppColors.grey),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('New', style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(MissionController controller, ThemeData theme) {
    return Expanded(
      child: Obx(() {
        final tasks = controller.tasks;
        return ListView.builder(
          itemCount: tasks.length + 1,
          itemBuilder: (context, index) {
            if (index == tasks.length) {
              return _newMission(theme);
            }

            final task = tasks[index];
            final String id = (task['id'] ?? '').toString();
            final bool isSelected = task['isSelected'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.scaffold,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.scaffold,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    activeColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.grey, width: 1.5),
                    onChanged: (_) => controller.selectTask(id),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      id,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade300,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.orange,
                      size: 20,
                    ),
                    onPressed: () {
                      showCustomDialog(
                        title: 'Edite',
                        message: 'Are you sure you want to edite?',
                        color: AppColors.orange,
                        icon: Icons.edit_rounded,
                        onConfirm: () {},
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: AppColors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      showCustomDialog(
                        title: 'Delete',
                        message: 'Are you sure you want to delete?',
                        color: AppColors.red,
                        icon: Icons.delete_rounded,
                        onConfirm: () {},
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

class SectionStatus extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const SectionStatus({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.grey),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500),
        ),
        SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
