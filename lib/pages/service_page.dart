import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import '../controllers/main_conroller.dart';
import '../controllers/management_controller.dart';
import '../services/toast_service.dart';
import '../units/app_colors.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_widget.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Management', style: theme.textTheme.titleLarge),
              CustomButton(
                text: "Default",
                icon: Icons.published_with_changes_rounded,
                onPressed: () {
                  controller.cards.value = controller.resetCards;
                  controller.syncToStorage();
                },
              ),
            ],
          ),
          _cardsGrid(controller, main, screen, theme, context),
        ],
      ),
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
                      fontSize: 12,
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

  void openAddFormDialog(
    BuildContext context,
    ManagementController controller,
    ThemeData theme,
  ) {
    final maxW = Get.width < 550 ? Get.width - 48 : 550.0;
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxW,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: _addFormWidget(controller, theme),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _addFormWidget(ManagementController controller, ThemeData theme) {
    final isEdit = controller.editCard.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          isEdit ? 'Edit Service' : 'New Service',
          style: TextStyle(
            color: isEdit ? AppColors.orange : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
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
              Obx(
                () => SizedBox(
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
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 10),
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
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 10),
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
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: AppColors.red),
                    onPressed: () {
                      if (controller.args.value > 1) {
                        controller.args.value--;
                        controller.data.value--;
                        _ensureArgControllers(
                          controller,
                          controller.args.value,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.green),
                    onPressed: () {
                      if (controller.args.value < 10) {
                        controller.args.value++;
                        controller.data.value++;
                        _ensureArgControllers(
                          controller,
                          controller.args.value,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "Cancel",
                icon: Icons.clear_rounded,
                foregroundColor: AppColors.grey,
                onPressed: () {
                  controller.addCard.value = false;
                  controller.editCard.value = false;
                  controller.clearFormat();
                  Get.back();
                },
              ),
            ),

            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: isEdit ? 'Update' : 'Save',
                icon: isEdit ? Icons.save_as_rounded : Icons.save_rounded,
                foregroundColor: isEdit ? AppColors.orange : AppColors.green,
                onPressed: () {
                  if (controller.labelTextField.value.text.isEmpty ||
                      controller.serviceTextField.value.text.isEmpty) {
                    ToastService.showToast(
                      title: 'Invalid',
                      description: 'Please fill in all fields.',
                      type: ToastificationType.warning,
                    );

                    return;
                  }

                  final result = <String, dynamic>{};
                  for (var i = 0; i < controller.args.value; i++) {
                    final k = controller.textControllerArgs[i].text.trim();
                    final v = controller.textControllerData[i].text.trim();
                    if (k.isEmpty) continue;
                    if (result.containsKey(k)) {
                      ToastService.showToast(
                        title: 'Duplicate key',
                        description: 'Argument "$k" duplicated.',
                        type: ToastificationType.warning,
                      );
                      return;
                    }
                    result[k] =
                        (v.toLowerCase() == 'true')
                            ? true
                            : (v.toLowerCase() == 'false')
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
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _newCard(
    BuildContext context,
    ManagementController controller,
    ThemeData theme,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        controller.clearFormat();
        controller.addCard.value = true;
        controller.isPublish.value = false;
        controller.editCard.value = false;
        openAddFormDialog(context, controller, theme);
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
    );
  }

  Widget _cardsGrid(
    ManagementController controller,
    MainController main,
    ScreenSize screen,
    ThemeData theme,
    BuildContext context,
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
            return _newCard(context, controller, theme);
          }

          final cardIndex = index;
          final card = controller.cards[cardIndex];

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              final bool cardPublish =
                  (card['isPublish'] == true) ||
                  (card['isPublish'] is String &&
                      card['isPublish'].toLowerCase() == 'true');

              Map argsMap = {};
              if (card['args'] is Map && (card['args'] as Map).isNotEmpty) {
                argsMap = controller.convertStringBools(card['args']);
              }

              final payload = {
                "op": cardPublish ? "publish" : "call_service",
                (cardPublish ? "topic" : "service"): card['service'],
                if (argsMap.isNotEmpty)
                  (cardPublish ? "msg" : "args"):
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

              openAddFormDialog(context, controller, theme);
            },
            onDoubleTap: () {
              showCustomDialog(
                title: 'Delete',
                message: 'Are you sure you want to delete?',
                color: AppColors.red,
                icon: Icons.delete_rounded,
                onConfirm: () {
                  controller.cards.removeAt(cardIndex);
                  controller.syncToStorage();
                  controller.clearFormat();
                  Get.back();
                },
              );
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

  void _ensureArgControllers(ManagementController c, int count) {
    while (c.textControllerArgs.length < count) {
      c.textControllerArgs.add(TextEditingController());
    }
    while (c.textControllerData.length < count) {
      c.textControllerData.add(TextEditingController());
    }
    while (c.textControllerArgs.length > count) {
      c.textControllerArgs.removeLast().dispose();
    }
    while (c.textControllerData.length > count) {
      c.textControllerData.removeLast().dispose();
    }
  }
}
