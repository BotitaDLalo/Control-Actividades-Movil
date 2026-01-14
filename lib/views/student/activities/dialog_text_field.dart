import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/utils.dart';
import 'package:aprende_mas/providers/providers.dart';

final dialogHeightProvider = StateProvider<double>(
  (ref) => 150.0,
);

class DialogTextField extends ConsumerStatefulWidget {
  final String? answer;
  final String buttonName;
  const DialogTextField({super.key, this.answer, required this.buttonName});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DialogTextFieldState();
}

class _DialogTextFieldState extends ConsumerState<DialogTextField> {
  late TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.answer ?? "");
  }
  // double dialogHeight = 150.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: const Text(
              'Respuesta',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              onChanged: (text) {
                ref.read(activityFormProvider.notifier).onAnswerChanged(text);
                ref.read(dialogHeightProvider.notifier).state = 150.0 + (controller.text.length / 2);
              },
              decoration: const InputDecoration(
                hintText: 'Escribe tu respuesta',
                // dejar que el tema global maneje los bordes y estilo
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: ElevatedButton(
              style: AppTheme.buttonSecondary,
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(activityFormProvider.notifier).onHasSubmission();
              },
              child: Text(widget.buttonName),
            ),
          ),
        ],
      ),
    );
  }
}