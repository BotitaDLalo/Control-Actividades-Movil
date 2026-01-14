import 'package:aprende_mas/config/utils/packages.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuccessDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onOkPressed;

  const SuccessDialog({
    super.key,
    required this.message,
    this.onOkPressed,
  });

  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onOkPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SuccessDialog(
        message: message,
        onOkPressed: onOkPressed,
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
            // Icono de éxito
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/palomita2.svg',
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
            // Botón OK
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onOkPressed?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}