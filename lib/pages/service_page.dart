import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/main_conroller.dart';
import '../controllers/management_controller.dart';
import '../units/app_colors.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/dashed_painter.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

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
            Expanded(child: ServiceScreen()),
          ],
        ),
      );
    } else if (screen.isPortrait) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(child: ServiceScreen()),
            buildResponsiveNavBar(context),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(child: ServiceScreen()),
            buildResponsiveNavBar(context),
          ],
        ),
      );
    }
  }
}

//----------------------  Service Content Responsive ---------------------//
class ServiceScreen extends StatelessWidget {
  ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);
    final theme = Theme.of(context);
    final ManagementController controller = Get.find();
    final MainController main = Get.find();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Obx(() {
        final isFormOpen =
            controller.addCard.value || controller.editCard.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFormOpen) ...[
              _addFormWidget(controller, theme),
              const SizedBox(height: 20),
            ] else ...[
              const SizedBox(height: 20),
              Text('Management', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              _cardsGrid(controller, main, screen, theme),
            ],
          ],
        );
      }),
    );
  }

  // ---------- Chip selector ----------
  Widget topicSelector(ManagementController controller) {
    return Obx(() {
      final String current =
          controller.isPublish.value ? 'Publish' : 'Call Service';
      final topics = controller.topics;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              topics.map((topic) {
                final bool isSelected = topic == current;
                return TextButton.icon(
                  onPressed:
                      () => controller.isPublish.value = (topic == 'Publish'),
                  icon: Icon(
                    topic == 'Publish'
                        ? Icons.file_upload_rounded
                        : Icons.route_rounded,
                    color: isSelected ? Colors.white : AppColors.grey,
                  ),
                  label: Text(
                    topic,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        isSelected ? AppColors.primary : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              }).toList(),
        ),
      );
    });
  }

  final inputFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9:./_-]')),
  ];

  Widget _addFormWidget(ManagementController controller, ThemeData theme) {
    final isEdit = controller.editCard.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.topRight,
          child: TextButton.icon(
            icon: const Icon(
              Icons.published_with_changes_rounded,
              color: AppColors.grey,
            ),
            label: const Text(
              "Default",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            style: TextButton.styleFrom(
              elevation: 2,
              backgroundColor: AppColors.card,
              foregroundColor: AppColors.grey,
              minimumSize: const Size(0, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.grey, width: 1.2),
              ),
            ),
            onPressed: () {
              controller.cards.value = controller.resetCards;
              controller.syncToStorage();
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.labelTextField.value,
                decoration: const InputDecoration(labelText: "Name"),
                inputFormatters: inputFormatter,
              ),
            ),
            const SizedBox(width: 12),
            Align(
              alignment: Alignment.centerRight,
              child: topicSelector(controller),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.serviceTextField.value,
          decoration: const InputDecoration(labelText: "Service"),
          inputFormatters: inputFormatter,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.scaffold,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.background, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Arguments', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: controller.args.value,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder:
                            (_, i) => TextField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: controller.textControllerArgs[i],
                              decoration: InputDecoration(
                                labelText: "Arg ${i + 1}",
                                fillColor: AppColors.background,
                                hoverColor: AppColors.card,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: controller.data.value,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder:
                            (_, i) => TextField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: controller.textControllerData[i],
                              decoration: InputDecoration(
                                labelText: "Data ${i + 1}",
                                fillColor: AppColors.background,
                                hoverColor: AppColors.card,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (controller.args.value > 1) {
                        controller.args.value--;
                        controller.data.value--;
                        if (controller.textControllerArgs.isNotEmpty) {
                          controller.textControllerArgs.removeLast();
                        }
                        if (controller.textControllerData.isNotEmpty) {
                          controller.textControllerData.removeLast();
                        }
                      }
                    },
                    icon: const Icon(Icons.remove_circle, color: AppColors.red),
                  ),
                  IconButton(
                    onPressed: () {
                      if (controller.args.value < 10) {
                        controller.args.value++;
                        controller.data.value++;
                        controller.textControllerArgs.add(
                          TextEditingController(),
                        );
                        controller.textControllerData.add(
                          TextEditingController(),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_circle, color: AppColors.green),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.clear_rounded, color: AppColors.grey),
                label: const Text(
                  "Cancel",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  elevation: 2,
                  backgroundColor: AppColors.card,
                  foregroundColor: AppColors.grey,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  controller.addCard.value = false;
                  controller.editCard.value = false;
                  controller.clearFormat();
                },
              ),
            ),
            if (controller.editCard.value) const SizedBox(width: 12),
            if (controller.editCard.value)
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_rounded, color: AppColors.red),
                  label: const Text(
                    "Delete",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  style: TextButton.styleFrom(
                    elevation: 2,
                    backgroundColor: AppColors.card,
                    foregroundColor: AppColors.red,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    showCustomDialog(
                      title: 'Delete',
                      message: 'Are you sure you want to delete?',
                      color: AppColors.red,
                      icon: Icons.delete_rounded,
                      onConfirm: () {
                        controller.cards.removeAt(controller.index.value);
                        controller.syncToStorage();
                        controller.clearFormat();
                        Get.back();
                        controller.editCard.value = false;
                      },
                    );
                  },
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: TextButton.icon(
                icon: Icon(
                  isEdit ? Icons.save_as_rounded : Icons.save_rounded,
                  color: isEdit ? AppColors.orange : AppColors.green,
                ),
                label: Text(
                  isEdit ? 'Update' : 'Save',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: TextButton.styleFrom(
                  elevation: 2,
                  backgroundColor: AppColors.card,
                  foregroundColor: isEdit ? AppColors.orange : AppColors.green,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (controller.labelTextField.value.text.isEmpty ||
                      controller.serviceTextField.value.text.isEmpty) {
                    Get.dialog(
                      AlertDialog(
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        actionsPadding: const EdgeInsets.all(16),
                        title: const Text(
                          'Invalid',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        content: const Text(
                          'Please fill in all fields.',
                          style: TextStyle(color: AppColors.grey, fontSize: 16),
                        ),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 46),
                              backgroundColor: AppColors.scaffold,
                              foregroundColor: AppColors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                                side: BorderSide(
                                  color: AppColors.grey,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Close',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  final result = <String, dynamic>{};
                  for (
                    var i = 0;
                    i < controller.textControllerArgs.length;
                    i++
                  ) {
                    final k = controller.textControllerArgs[i].text;
                    final v = controller.textControllerData[i].text;
                    if (k.trim().isEmpty) continue;
                    result[k] =
                        v.toLowerCase() == 'true'
                            ? true
                            : v.toLowerCase() == 'false'
                            ? false
                            : v;
                  }

                  if (controller.editCard.value) {
                    final idx = controller.index.value;
                    final entry = {
                      "args": result,
                      "label": controller.labelTextField.value.text,
                      "service": controller.serviceTextField.value.text,
                      "isPublish": controller.isPublish.value,
                    };
                    if (idx >= 0 && idx < controller.cards.length) {
                      controller.cards[idx] = entry;
                    } else {
                      controller.cards.add(entry);
                    }
                    controller.index.value = -1;
                    controller.editCard.value = false;
                  } else {
                    controller.cards.add({
                      "args": result,
                      "label": controller.labelTextField.value.text,
                      "service": controller.serviceTextField.value.text,
                      "isPublish": controller.isPublish.value,
                    });
                    controller.addCard.value = false;
                  }

                  controller.clearFormat();
                  controller.syncToStorage();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _newCardTile(ManagementController controller, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          controller.clearFormat();
          controller.addCard.value = true;
          controller.isPublish.value = false;
          controller.editCard.value = false;
        },
        child: CustomPaint(
          foregroundPainter: DashedPainter(color: AppColors.grey),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('New', style: theme.textTheme.labelMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardsGrid(
    ManagementController controller,
    MainController main,
    ScreenSize screen,
    ThemeData theme,
  ) {
    return Obx(
      () => GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screen.isPortrait ? 2 : 4,
          mainAxisExtent: 150,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: controller.cards.length + 1,
        itemBuilder: (_, index) {
          if (index == controller.cards.length) {
            return _newCardTile(controller, theme);
          }

          final cardIndex = index;
          final card = controller.cards[cardIndex];

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Map argsMap = {};
              if (card['args'] is Map && (card['args'] as Map).isNotEmpty) {
                argsMap = controller.convertStringBools(card['args']);
              }
              final payload = {
                "op": controller.isPublish.value ? "publish" : "call_service",
                controller.isPublish.value ? "topic" : "service":
                    card['service'],
                if (argsMap.isNotEmpty)
                  (controller.isPublish.value ? "msg" : "args"):
                      (card['service'] == '/speak'
                          ? {
                            "text": argsMap['text'],
                            "inquirer": "",
                            "override": true,
                          }
                          : argsMap),
              };
              main.sendData(jsonEncode(payload));
            },
            onLongPress: () {
              controller.editCard.value = true;
              controller.addCard.value = false;

              controller.index.value = cardIndex;
              controller.labelTextField.value.text = card['label'];
              controller.serviceTextField.value.text = card['service'];

              final argsLen = (card['args'] as Map).length;
              controller.args.value = argsLen;
              controller.data.value = argsLen;

              final cardIsPublish = card['isPublish'];
              controller.isPublish.value =
                  (cardIsPublish is String)
                      ? cardIsPublish.toLowerCase() == 'true'
                      : (cardIsPublish == true);

              controller.textControllerArgs.clear();
              controller.textControllerData.clear();
              (card['args'] as Map).forEach((k, v) {
                controller.textControllerArgs.add(
                  TextEditingController(text: k.toString()),
                );
                controller.textControllerData.add(
                  TextEditingController(text: v.toString()),
                );
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.scaffold,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        card['label'],
                        style: theme.textTheme.labelMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
