import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _showLinkDialog(BuildContext context, WidgetRef ref) {
    TextEditingController linkController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insertar Enlace', style: TextStyle(color: Colors.black)),
          content: TextField(
            controller: linkController,
            decoration: const InputDecoration(hintText: 'Ingresa la URL'),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
                backgroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                if (linkController.text.isNotEmpty) {
                  List<String> updatedLinks = List.from(ref.read(activityFormProvider).links);
                  updatedLinks.add(linkController.text);
                  ref.read(activityFormProvider.notifier).onLinksChanged(updatedLinks);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
  // double dialogHeight = 150.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Respuesta',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png', 'gif', 'mp4', 'avi', 'mov', 'zip', 'rar', 'ppt', 'pptx', 'xls', 'xlsx', 'csv'],
                  );
                  if (result != null) {
                    List<PlatformFile> files = result.files;
                    ref.read(activityFormProvider.notifier).onFilesChanged([...ref.read(activityFormProvider).files, ...files]);
                  }
                },
                icon: SvgPicture.asset('assets/icons/documento.svg', width: 20, height: 20, colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn)),
                label: const Text('Archivo'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  foregroundColor: Colors.blue,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  _showLinkDialog(context, ref);
                },
                icon: SvgPicture.asset('assets/icons/link.svg', width: 20, height: 20, colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn)),
                label: const Text('Enlace'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  foregroundColor: Colors.blue,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mostrar archivos seleccionados
          if (ref.watch(activityFormProvider).files.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Archivos adjuntos:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...ref.watch(activityFormProvider).files.map((file) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/icons/documento.svg', width: 50, height: 50, colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            file.name ?? 'Archivo desconocido',
                            style: const TextStyle(fontSize: 14),
                            maxLines: null,
                          ),
                        ),
                        IconButton(
                          icon: SvgPicture.asset('assets/icons/eliminar4.svg', width: 35, height: 35, colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)),
                          onPressed: () {
                            List<PlatformFile> updatedFiles = List.from(ref.read(activityFormProvider).files);
                            updatedFiles.remove(file);
                            ref.read(activityFormProvider.notifier).onFilesChanged(updatedFiles);
                          },
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          // Mostrar enlaces seleccionados
          if (ref.watch(activityFormProvider).links.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enlaces:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...ref.watch(activityFormProvider).links.map((link) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/icons/link.svg', width: 50, height: 50, colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse(link.startsWith('http') ? link : 'https://$link');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Text(
                              link,
                              style: const TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline),
                              maxLines: null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: SvgPicture.asset('assets/icons/eliminar4.svg', width: 35, height: 35, colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)),
                          onPressed: () {
                            List<String> updatedLinks = List.from(ref.read(activityFormProvider).links);
                            updatedLinks.remove(link);
                            ref.read(activityFormProvider.notifier).onLinksChanged(updatedLinks);
                          },
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.white,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(activityFormProvider.notifier).onHasSubmission();
                  },
                  child: Text(widget.buttonName),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.white,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}