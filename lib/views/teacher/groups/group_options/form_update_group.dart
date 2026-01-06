import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/views/widgets/buttons/button_form.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';

class FormUpdateGroup extends ConsumerStatefulWidget {
  final int id;
  final String groupName;
  final String description;
  final String? accesCode;
  // final String colorCode;

  const FormUpdateGroup(
      {super.key,
      required this.id,
      required this.groupName,
      required this.description,
      this.accesCode,
      // required this.colorCode
      });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FormUpdateGroupState();
}

class _FormUpdateGroupState extends ConsumerState<FormUpdateGroup> {
  @override
  Widget build(BuildContext context) {
    final formUpdateGroupNotifier = ref.read(formGroupsProvider.notifier);

    // Future<void> showColorDialog() async {
    //   showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: const Text('Escoge un color'),
    //       content: SingleChildScrollView(
    //         child: BlockPicker(
    //           availableColors: AppTheme.availableColors,
    //           pickerColor: formUpdateGroup.pickerColor,
    //           onColorChanged: (color) {
    //             formUpdateGroupNotifier.onUpdateGroupColorChanged(color);
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

    void goRouterPop() {
      context.pop();
    }

    ref.listen(formGroupsProvider, (previous, next) {
      if (next.isFormPosted && !next.isPosting) {
        SuccessDialog.show(context, message: "Grupo actualizado exitosamente", onOkPressed: goRouterPop);
      } else if (!next.isFormPosted && !next.isPosting && previous?.isPosting == true) {
        ErrorDialog.show(context, message: "Error al actualizar el grupo");
      }
    });
    
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
            child: Text(
              'Actualizar grupo',
              style: Theme.of(context).textTheme.titleLarge,
              // style: TextStyle(color: formCreateGroup.pickerColor),
            ),
          ),
          const SizedBox(height: 10),
          CustomTextFormField(
            label: widget.groupName,
            onChanged: formUpdateGroupNotifier.onUpdateGroupNameChanged,
          ),
          const SizedBox(height: 10),
          CustomTextFormField(
            label: widget.description,
            onChanged: formUpdateGroupNotifier.onUpdateGroupDescriptionChanged,
          ),
          const SizedBox(height: 15),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     Container(
          //         height: 45,
          //         width: 45,
          //         decoration: BoxDecoration(
          //           color: formUpdateGroup.pickerColor ==
          //                   const Color.fromARGB(0, 255, 255, 255)
          //               ? AppTheme.stringToColor(widget.colorCode)
          //               : formUpdateGroup.pickerColor,
          //           border: Border.all(
          //             color: formUpdateGroup.pickerColor ==
          //                     const Color.fromARGB(0, 255, 255, 255)
          //                 ? AppTheme.stringToColor(widget.colorCode)
          //                 : formUpdateGroup.pickerColor,
          //           ),
          //           borderRadius: BorderRadius.circular(50),
          //           boxShadow: [
          //             BoxShadow(
          //                 color: formUpdateGroup.pickerColor ==
          //                         const Color.fromARGB(0, 255, 255, 255)
          //                     ? AppTheme.stringToColor(widget.colorCode)
          //                     : formUpdateGroup.pickerColor,
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
          //         foregroundColor: formUpdateGroup.pickerColor ==
          //                 const Color.fromARGB(0, 255, 255, 255)
          //             ? AppTheme.stringToColor(widget.colorCode)
          //             : formUpdateGroup.pickerColor,
          //         fixedSize: const Size.fromHeight(45),
          //         // side: BorderSide(color: _colorThemes[1]),
          //         side: BorderSide(
          //           color: formUpdateGroup.pickerColor ==
          //                   const Color.fromARGB(0, 255, 255, 255)
          //               ? AppTheme.stringToColor(widget.colorCode)
          //               : formUpdateGroup.pickerColor,
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
          Container(
            alignment: const Alignment(0.9, 2),
            child: ButtonForm(
                buttonName: 'Actualizar',
                onPressed: () async {
                  if (!ref.read(formGroupsProvider).isPosting) {
                    await formUpdateGroupNotifier.onUpdateGroupSubmit(widget.id,
                        widget.groupName, widget.description);
                  }
                },
                style: AppTheme.buttonPrimary),
          )
        ],
      ),
    );
  }
}
