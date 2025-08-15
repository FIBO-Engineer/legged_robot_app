import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/main_conroller.dart';
import '../units/app_colors.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_widget.dart';

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
    MainController c = Get.find();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.addCard.value || c.editCard.value) _addFormWidget(c, theme),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Service Management', style: theme.textTheme.titleLarge),
                const SizedBox(width: 12),
                if (!c.addCard.value && !c.editCard.value)
                  TextButton.icon(
                    icon: Icon(Icons.add_rounded, color: Colors.white),
                    label: Text(
                      'New Service',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      minimumSize: const Size(0, 46),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      c.clearTextController();
                      c.addCard.value = true;
                      c.isPublish.value = false;
                      c.editCard.value = false;
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _cardsGrid(c, screen),
          ],
        );
      }),
    );
  }

  // ---------- Chip selector ----------
  Widget topicSelector(MainController controller) {
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

  // ---------- Form ----------
  Widget _addFormWidget(MainController c, ThemeData theme) {
    final isEdit = c.editCard.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Add New Service', style: theme.textTheme.titleLarge),
            const SizedBox(width: 12),
            TextButton.icon(
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
                c.cards.value = c.resetCards;
                c.syncToStorage();
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: c.labelTextField.value,
                decoration: const InputDecoration(labelText: "Label"),
                inputFormatters: inputFormatter,
              ),
            ),
            const SizedBox(width: 12),
            Align(alignment: Alignment.centerRight, child: topicSelector(c)),
          ],
        ),

        const SizedBox(height: 12),

        TextField(
          controller: c.serviceTextField.value,
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
              Text('Add Parameters', style: theme.textTheme.titleMedium),
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
                        itemCount: c.args.value,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder:
                            (_, i) => TextField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: c.textControllerArgs[i],
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
                        itemCount: c.data.value,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder:
                            (_, i) => TextField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              controller: c.textControllerData[i],
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (c.args.value > 1) {
                        c.args.value--;
                        c.data.value--;
                        if (c.textControllerArgs.isNotEmpty) {
                          c.textControllerArgs.removeLast();
                        }
                        if (c.textControllerData.isNotEmpty) {
                          c.textControllerData.removeLast();
                        }
                      }
                    },
                    icon: const Icon(Icons.remove_circle, color: AppColors.red),
                  ),
                  IconButton(
                    onPressed: () {
                      if (c.args.value < 10) {
                        c.args.value++;
                        c.data.value++;
                        c.textControllerArgs.add(TextEditingController());
                        c.textControllerData.add(TextEditingController());
                      }
                    },
                    icon: const Icon(Icons.add_circle, color: AppColors.green),
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
                  c.addCard.value = false;
                  c.editCard.value = false;
                  c.clearTextController();
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
                  if (c.labelTextField.value.text.isEmpty ||
                      c.serviceTextField.value.text.isEmpty) {
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
                  for (var i = 0; i < c.textControllerArgs.length; i++) {
                    final k = c.textControllerArgs[i].text;
                    final v = c.textControllerData[i].text;
                    if (k.trim().isEmpty) continue;
                    result[k] =
                        v.toLowerCase() == 'true'
                            ? true
                            : v.toLowerCase() == 'false'
                            ? false
                            : v;
                  }

                  if (c.editCard.value) {
                    final idx = c.editIndex.value;
                    final entry = {
                      "args": result,
                      "label": c.labelTextField.value.text,
                      "service": c.serviceTextField.value.text,
                      "isPublish": c.isPublish.value,
                    };
                    if (idx >= 0 && idx < c.cards.length) {
                      c.cards[idx] = entry;
                    } else {
                      c.cards.add(entry);
                    }
                    c.editIndex.value = -1;
                    c.editCard.value = false;
                  } else {
                    c.cards.add({
                      "args": result,
                      "label": c.labelTextField.value.text,
                      "service": c.serviceTextField.value.text,
                      "isPublish": c.isPublish.value,
                    });
                    c.addCard.value = false;
                  }

                  c.clearTextController();
                  c.syncToStorage();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _cardsGrid(MainController c, ScreenSize screen) {
    return Obx(
      () => GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screen.isPortrait ? 2 : 4,
          mainAxisExtent: 150,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: c.cards.length,
        itemBuilder: (_, index) {
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              var card = c.cards[index];
              Map argsMap = {};
              if (card['args'] is Map && (card['args'] as Map).isNotEmpty) {
                argsMap = c.convertStringBools(card['args']);
              }
              final payload = {
                "op": c.isPublish.value ? "publish" : "call_service",
                c.isPublish.value ? "topic" : "service": card['service'],
                if (argsMap.isNotEmpty)
                  (c.isPublish.value ? "msg" : "args"):
                      (card['service'] == '/speak'
                          ? {
                            "text": argsMap['text'],
                            "inquirer": "",
                            "override": true,
                          }
                          : argsMap),
              };
              c.sendData(jsonEncode(payload));
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
                        c.cards[index]['label'],
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Row(
                      children: [
                        CircleButton(
                          size: 36,
                          iconSize: 18,
                          icon: Icons.edit_rounded,
                          backgroundColor: AppColors.scaffold,
                          borderColor: AppColors.grey,
                          iconColor: AppColors.grey,
                          onPressed: () {
                            c.editCard.value = true;
                            c.addCard.value = false;

                            c.editIndex.value = index;
                            c.labelTextField.value.text =
                                c.cards[index]['label'];
                            c.serviceTextField.value.text =
                                c.cards[index]['service'];

                            final argsLen =
                                (c.cards[index]['args'] as Map).length;
                            c.args.value = argsLen;
                            c.data.value = argsLen;

                            final cardIsPublish = c.cards[index]['isPublish'];
                            c.isPublish.value =
                                (cardIsPublish is String)
                                    ? cardIsPublish.toLowerCase() == 'true'
                                    : (cardIsPublish == true);

                            c.textControllerArgs.clear();
                            c.textControllerData.clear();
                            (c.cards[index]['args'] as Map).forEach((k, v) {
                              c.textControllerArgs.add(
                                TextEditingController(text: k.toString()),
                              );
                              c.textControllerData.add(
                                TextEditingController(text: v.toString()),
                              );
                            });
                          },
                        ),
                        SizedBox(width: 4),
                        CircleButton(
                          size: 36,
                          iconSize: 18,
                          icon: Icons.delete_rounded,
                          backgroundColor: AppColors.scaffold,
                          borderColor: AppColors.grey,
                          iconColor: AppColors.grey,
                          onPressed: () {
                            showCustomDialog(
                              title: 'Delete',
                              message: 'Are you sure you want to delete?',
                              color: AppColors.red,
                              icon: Icons.delete_rounded,
                              onConfirm: () {
                                if (c.editIndex.value == index) {
                                  c.editIndex.value = -1;
                                  c.editCard.value = false;
                                }
                                c.cards.removeAt(index);
                                c.syncToStorage();
                                c.clearTextController();
                                Get.back();
                              },
                            );
                          },
                        ),
                      ],
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
