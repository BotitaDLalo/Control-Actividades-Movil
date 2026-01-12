import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';
import 'package:aprende_mas/providers/data/key_value_storage_service_providers.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/subjects/subjects_provider.dart';
import 'package:aprende_mas/providers/groups/groups_provider.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/warning_confirmation_dialog.dart';
import 'package:aprende_mas/providers/groups/form_groups_provider.dart';
import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/views/widgets/inputs/custom_text_form_field.dart';
import 'package:aprende_mas/views/widgets/buttons/button_form.dart';

class GroupModifySubjectCard extends ConsumerWidget {
  final int index;
  final String subjectName;
  final String description;

  const GroupModifySubjectCard({
    super.key,
    required this.index,
    required this.subjectName,
    required this.description,
  });

  LinearGradient _makeGradient(int id) {
    final hue = (id * 47) % 360;
    final c1 = HSLColor.fromAHSL(1, hue.toDouble(), 0.62, 0.48).toColor();
    final c2 = HSLColor.fromAHSL(1, (hue + 25) % 360, 0.70, 0.40).toColor();
    return LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, c2]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formCreateGroupNotifier = ref.read(formGroupsProvider.notifier);
    final cn = ref.watch(catalogNamesProvider);
    final role = ref.watch(roleFutureProvider).maybeWhen(
          data: (data) => data,
          orElse: () => "",
        );

    Future<void> showUpdateSubjectForm(
        String subjectName, String description) async {
      final subjectNameController = TextEditingController(text: subjectName);
      final subjectDescriptionController =
          TextEditingController(text: description);

      formCreateGroupNotifier.onSubjectNameChanged(subjectName);
      formCreateGroupNotifier.onSubjectDescription(description);

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: const Alignment(-0.8, 1),
                    child: Text(
                      'Modificar materia',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Nombre de la materia',
                    textEditingController: subjectNameController,
                    onChanged: formCreateGroupNotifier.onUpdateSubjNameChanged,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Descripción',
                    textEditingController: subjectDescriptionController,
                    onChanged:
                        formCreateGroupNotifier.onUpdateSubjDescriptionChanged,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: const Alignment(0.9, 2),
                    child: ButtonForm(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        fixedSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      buttonName: "Actualizar",
                      onPressed: () async {
                        formCreateGroupNotifier.onUpdateIndexSubjChanged(index);
                        formCreateGroupNotifier.onUpdateSubjectsSubmit();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    alignment: const Alignment(0.9, 2),
                    child: ButtonForm(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        fixedSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      buttonName: "Cancelar",
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    final gradient = _makeGradient(index);

    return GestureDetector(
      onTap: () {
        showUpdateSubjectForm(subjectName, description);
      },
      child: LayoutBuilder(builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final width = availableWidth * 0.5;
        final height = MediaQuery.of(context).size.height * 0.15;

        return Container(
          margin: ResponsiveUtils.margin(context, horizontal: 0.02, vertical: 0.01),
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(context.radius(0.055)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: context.width(0.03),
                  offset: Offset(0, context.height(0.008)))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.radius(0.055)),
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned(
                    right: -00,
                    bottom: -00,
                    child: Opacity(
                      opacity: 0.12,
                      child: SvgPicture.asset(
                        'assets/icons/book1.svg',
                        width: min(width * 0.8, height * 1.0),
                        height: min(width * 0.5, height * 1.0),
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Padding(
                    padding: ResponsiveUtils.padding(context, horizontal: 0.04, vertical: 0.015),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subjectName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: context.fontSize(16),
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: context.height(0.008)),
                        Text(
                          description.trim().isNotEmpty ? description.trim() : "Sin descripción",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: context.fontSize(13),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
