import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/widgets/buttons/button_form.dart';
import 'package:aprende_mas/views/widgets/buttons/custom_rounded_button.dart';

class CustomAlertDialog extends ConsumerWidget {
  final String message;
  final String comment;
  final String buttonContinueName;
  final String buttonCancelName;
  final VoidCallback onPressedContinue;
  final VoidCallback onPressedCancel;

  const CustomAlertDialog({
    super.key,
    required this.message,
    required this.comment,
    required this.buttonCancelName,
    required this.buttonContinueName,
    required this.onPressedContinue,
    required this.onPressedCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      title: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Corrección para desbordamiento vertical (Overflow)
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              textAlign: TextAlign.center,
              comment,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Botón CANCELAR (Secundario/Neutro)
                CustomRoundedButton(
                    text: buttonCancelName, // 'Cancelar'
                    onPressed: onPressedCancel,
                    // Estilo de botón secundario
                    backgroundColor: Colors.white, 
                    textColor: const Color(0xFF283043),
                    borderRadius: 10,
                ),
                // Botón CONTINUAR/ELIMINAR (Destructivo)
                CustomRoundedButton(
                    text: buttonContinueName, // 'Eliminar'
                    onPressed: onPressedContinue,
                    // Estilo de botón destructivo (ROJO)
                    backgroundColor: const Color(0xFF283043),
                    textColor: Colors.white,
                    borderRadius: 10,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}