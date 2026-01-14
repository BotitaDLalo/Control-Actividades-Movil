import 'package:aprende_mas/config/utils/packages.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WarningConfirmationDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onConfirmPressed;
  final VoidCallback? onCancelPressed;

  const WarningConfirmationDialog({
    super.key,
    required this.message,
    this.onConfirmPressed,
    this.onCancelPressed,
  });

  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onConfirmPressed,
    VoidCallback? onCancelPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => WarningConfirmationDialog(
        message: message,
        onConfirmPressed: onConfirmPressed,
        onCancelPressed: onCancelPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de advertencia
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange[800], // Naranja oscuro
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/alert2.svg',
                  width: 40,
                  height: 40,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Mensaje
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            // Botones
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancelPressed?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirmPressed?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800], // Naranja oscuro
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}