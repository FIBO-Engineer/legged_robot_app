import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/main_conroller.dart';
import '../units/app_colors.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';

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
      padding: const EdgeInsets.all(12),
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Top: Add bar or nothing when form is open ----------------
            if (!c.addCard.value && !c.editCard.value)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    c.clearTextController();
                    c.isPublish.value = false;
                    c.addCard.value = true;
                    c.editCard.value = false;
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),

                    backgroundColor: AppColors.card,
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text(
                    'Add',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            // ---------------- Form (Add/Edit) ----------------
            if (c.addCard.value || c.editCard.value) _addFormWidget(c, theme),
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
          controller.isPublish.value ? 'Publish' : 'CallService';
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
                  label: Text(
                    topic,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isSelected ? Colors.white : AppColors.kNavColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        isSelected ? AppColors.primary : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(0, 46),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Add new service', style: theme.textTheme.titleMedium),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.card,
                foregroundColor: AppColors.kNavColor,
                minimumSize: const Size(0, 50),
              ),
              child: Text(
                "Default",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: () {
                c.cards.value = c.resetCards;
                c.syncToStorage();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: Row(
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
        ),

        const SizedBox(height: 8),

        TextField(
          controller: c.serviceTextField.value,
          decoration: const InputDecoration(labelText: "Service"),
          inputFormatters: inputFormatter,
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: c.args.value,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder:
                      (_, i) => TextField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        controller: c.textControllerArgs[i],
                        decoration: InputDecoration(labelText: "Arg ${i + 1}"),
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: c.data.value,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder:
                      (_, i) => TextField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        controller: c.textControllerData[i],
                        decoration: InputDecoration(labelText: "Data ${i + 1}"),
                      ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                if (c.args.value > 1) {
                  c.args.value--;
                  c.data.value--;
                  c.textControllerArgs.removeLast();
                  c.textControllerData.removeLast();
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.card,
                foregroundColor: AppColors.red,
                minimumSize: const Size(0, 46),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: () {
                c.addCard.value = false;
                c.editCard.value = false;
                c.clearTextController();
              },
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.card,
                foregroundColor: isEdit ? AppColors.orange : AppColors.green,
                minimumSize: const Size(0, 50),
              ),
              child: Text(
                isEdit ? 'Edit' : 'Save',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: () {
                if (c.labelTextField.value.text.isEmpty ||
                    c.serviceTextField.value.text.isEmpty) {
                  Get.dialog(
                    AlertDialog(
                      title: const Text(
                        'Invalid Data',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      content: const Text('Please fill all data'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Close', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                // build args
                final result = <String, dynamic>{};
                for (var i = 0; i < c.textControllerArgs.length; i++) {
                  final k = c.textControllerArgs[i].text;
                  final v = c.textControllerData[i].text;
                  result[k] =
                      v.toLowerCase() == 'true'
                          ? true
                          : v.toLowerCase() == 'false'
                          ? false
                          : v;
                }

                if (c.editCard.value) {
                  final idx = c.editIndex.value; // <— ใช้ index ที่เราเก็บไว้
                  if (idx >= 0 && idx < c.cards.length) {
                    c.cards[idx] = {
                      "args": result,
                      "label": c.labelTextField.value.text,
                      "service": c.serviceTextField.value.text,
                      "isPublish": c.isPublish.value,
                    };
                  } else {
                    // กันพลาด: ถ้า index หลุด ให้ add แทน
                    c.cards.add({
                      "args": result,
                      "label": c.labelTextField.value.text,
                      "service": c.serviceTextField.value.text,
                      "isPublish": c.isPublish.value,
                    });
                  }
                  c.editIndex.value = -1;
                  c.editCard.value = false;
                } else {
                  // Add ใหม่
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
          ],
        ),
        const SizedBox(height: 12),
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
          crossAxisCount: screen.isPortrait ? 3 : 6,
          mainAxisExtent: 100,
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
            onLongPress: () {
              c.editCard.value = true;
              c.addCard.value = false;

              c.editIndex.value = index; // <— เก็บ index ที่กำลังแก้
              c.labelTextField.value.text = c.cards[index]['label'];
              c.serviceTextField.value.text = c.cards[index]['service'];

              final argsLen = (c.cards[index]['args'] as Map).length;
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
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  math.Random().nextInt(100),
                  math.Random().nextInt(100),
                  math.Random().nextInt(100),
                  1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // ข้อความกลางการ์ด
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
                    right: 8,
                    bottom: 8,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        if (c.editIndex.value == index) {
                          c.editIndex.value = -1;
                          c.editCard.value = false;
                        }
                        c.cards.removeAt(index);
                        c.syncToStorage();
                        c.clearTextController();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: AppColors.grey,
                          size: 16,
                        ),
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
