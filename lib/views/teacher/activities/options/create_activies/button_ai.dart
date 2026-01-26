import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/activity/activty_form_provider.dart';
import 'package:aprende_mas/providers/chat_gemini/ai_activity.dart';

class ButtonAI extends ConsumerWidget {
  final TextEditingController tituloController;
  final TextEditingController descripcionController;
  final VoidCallback? onSuggestionUsed;

  const ButtonAI({
    super.key,
    required this.tituloController,
    required this.descripcionController,
    this.onSuggestionUsed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () async {
        final ai = ref.read(aiActivityProvider);

        // Crear un prompt con la información actual del formulario
        final prompt =
            "Genera una actividad basada en el título: '${tituloController.text}' y descripción: '${descripcionController.text}'.";

        // Llamar a la API de Gemini
        final suggestion = await ai.generateActivitySuggestion(prompt);

        if (suggestion != null && context.mounted) {
          _showSuggestionDialog(context, suggestion, ref);
        }
      },
      child: const Icon(Icons.lightbulb),
    );
  }

  void _showSuggestionDialog(BuildContext context, String suggestion, WidgetRef ref) {
    // Dividir la respuesta en sugerencias (aquí se dividen por saltos de línea)
    List<String> suggestions = suggestion.split('\n');

    // Filtrar líneas vacías y asegurarnos de que haya exactamente 3 sugerencias
    suggestions = suggestions.where((line) => line.isNotEmpty).toList();

    // Limitar las sugerencias a un máximo de 3
    if (suggestions.length > 3) {
      suggestions = suggestions.sublist(0, 3);
    }

    // Limpiar las sugerencias de los números de lista, si los hay
    suggestions = suggestions.map((suggestionText) {
      return suggestionText.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
    }).toList();

    // Usar un controlador para gestionar la selección de la sugerencia
    String selectedSuggestion = suggestions.isNotEmpty ? suggestions[0] : '';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero, // Eliminar márgenes para ocupar toda la pantalla
          child: SafeArea(
            child: StatefulBuilder(
              // Usamos StatefulBuilder para actualizar el estado dentro del diálogo
              builder: (context, setState) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.blueAccent,
                      child: const Text(
                        "📢 Sugerencia de IA",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        // Hacer que las sugerencias sean desplazables
                        child: Column(
                          children: [
                            // Crear una lista de opciones de sugerencias usando RadioListTile
                            for (var suggestionText in suggestions)
                              RadioListTile<String>(
                                title: Text(suggestionText),
                                value: suggestionText,
                                groupValue: selectedSuggestion,
                                onChanged: (String? value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedSuggestion = value; // Actualizamos la selección
                                    });
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("❌ Cancelar"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                descripcionController.text = selectedSuggestion;
                                ref.read(activityFormProvider.notifier).onDescripcionChanged(selectedSuggestion);
                                if (onSuggestionUsed != null) onSuggestionUsed!();
                                await Future.delayed(const Duration(milliseconds: 50));
                                Navigator.pop(context);
                              },
                              child: const Text("✔️ Usar sugerencia"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
