import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/groups/form_groups_provider.dart';
import 'package:aprende_mas/views/widgets/buttons/button_form.dart';
import 'package:aprende_mas/views/views.dart';

class FormCreateGroup extends ConsumerWidget {
  const FormCreateGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formCreateGroup = ref.watch(formGroupsProvider);
    final formCreateGroupNotifier = ref.read(formGroupsProvider.notifier);

    // ref.listen(
    //   formGroupsProvider,
    //   (previous, next) {
    //     if (next.isFormPosted && !next.isPosting) {
    //       context.pop();
    //     }
    //   },
    // );

    // Future<void> showColorDialog() async {
    //   showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: const Text('Escoge un color'),
    //       content: SingleChildScrollView(
    //         child: BlockPicker(
    //           availableColors: AppTheme.availableColors,
    //           pickerColor: formCreateGroup.pickerColor,
    //           onColorChanged: (color) {
    //             formCreateGroupNotifier.onColorCodeChanged(color);
    //           },
    //         ),
    //       ),
    //       actions: <Widget>[
    //         ElevatedButton(
    //           child: const Text('Hecho'),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     ),
    //   );
    // }

    Future<void> showSubjectDialog() async {
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
                      'Crear materia',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Nombre de la materia',
                    onChanged: formCreateGroupNotifier.onSubjectNameChanged,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    label: 'Descripción',
                    onChanged: formCreateGroupNotifier.onSubjectDescription,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    alignment: const Alignment(0.9, 2),
                    child: ButtonForm(
                      style: AppTheme.buttonPrimary,
                      buttonName: "Agregar materia",
                      onPressed: () {
                        formCreateGroupNotifier.onSubjectSubmit();

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

    void goRouterPop() {
      context.pop();
    }

    return Container(
      width: 350,
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            alignment: const Alignment(-0.8, 1),
            
          ),
          const SizedBox(height: 10),
          CustomTextFormField(
            label: 'Nombre del grupo',
            onChanged: formCreateGroupNotifier.onGroupNameChanged,
            errorMessage: formCreateGroup.isFormPosted
                ? formCreateGroup.groupName.errorMessage
                : null,
          ),
          const SizedBox(height: 10),
          CustomTextFormField(
            label: 'Descripción',
            onChanged: formCreateGroupNotifier.onDescriptionChanged,
          ),
          const SizedBox(height: 15),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     Container(
          //         height: 45,
          //         width: 45,
          //         decoration: BoxDecoration(
          //           color: formCreateGroup.pickerColor,
          //           border: Border.all(
          //             color: formCreateGroup.pickerColor ==
          //                     const Color.fromARGB(0, 255, 255, 255)
          //                 ? const Color.fromARGB(100, 0, 0, 0)
          //                 : formCreateGroup.pickerColor,
          //           ),
          //           borderRadius: BorderRadius.circular(50),
          //           boxShadow: [
          //             BoxShadow(
          //                 color: formCreateGroup.pickerColor,
          //                 spreadRadius: 0.1,
          //                 blurRadius: 3,
          //                 offset: const Offset(1, 1.5)),
          //           ],
          //         )),
          //     const SizedBox(width: 10),
          //     ButtonForm(
          //       // style: AppTheme.buttonSecondary,
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          //         foregroundColor: formCreateGroup.pickerColor ==
          //                 const Color.fromARGB(0, 255, 255, 255)
          //             ? const Color.fromARGB(150, 0, 0, 0)
          //             : formCreateGroup.pickerColor,
          //         fixedSize: const Size.fromHeight(45),
          //         // side: BorderSide(color: _colorThemes[1]),
          //         side: BorderSide(
          //           color: formCreateGroup.pickerColor ==
          //                   const Color.fromARGB(0, 255, 255, 255)
          //               ? const Color.fromARGB(100, 0, 0, 0)
          //               : formCreateGroup.pickerColor,
          //         ),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10), // border radius
          //         ),
          //       ),
          //       buttonName: "Seleccionar Color",
          //       onPressed: () => showColorDialog(),
          //     ),

          //   ],
          // ),
          // const SizedBox(height: 15),
          Row(
            children: [
              Container(
                alignment: const Alignment(-0.8, 1),
                child: Text(
                  'Materias',
                  style: Theme.of(context).textTheme.titleLarge,
                  // style: TextStyle(color: formCreateGroup.pickerColor),
                ),
              ),
              const SizedBox(width: 10),
              ButtonForm(
                  buttonName: "Agregar",
                  onPressed: () {
                    showSubjectDialog();
                  },
                  style: AppTheme.buttonTertiary)
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 210,
            width: 350,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: formCreateGroup.subjectsRow
                    .asMap()
                    .entries
                    .map((item) => GroupModifySubjectCard(
                        index: item.key,
                        subjectName: item.value.nombreMateria,
                        description: item.value.descripcion ?? ""))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            alignment: const Alignment(0.9, 2),
            child: ButtonForm(
                style: AppTheme.buttonPrimary,
                buttonName: "Crear grupo",
                onPressed: () async {
                  if (formCreateGroup.isPosting) {
                    return;
                  }
                  await formCreateGroupNotifier.onFormSubmit();
                  if (formCreateGroup.isFormPosted) {
                    goRouterPop();
                  }
                }),
          )
        ],
      ),
    );
  }
}
