import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/authentication/form_confirmation_code_provider.dart';
import 'package:flutter/services.dart';

class TextfieldNumber extends ConsumerWidget {
  final Function(String) onChanged;
  const TextfieldNumber({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 68,
      width: 64,
      child: TextField(
        cursorColor: Colors.black,
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
            onChanged(value);
          }
        },
        decoration: const InputDecoration(
          floatingLabelStyle: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          isDense: true,
          // Dejar que el tema global maneje los bordes (underline por defecto)
        ),
        style: Theme.of(context).textTheme.headlineMedium,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
      ),
    );
  }
}
