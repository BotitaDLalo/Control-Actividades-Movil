import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/notices/notices_form_provider.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/buttons/custom_rounded_button.dart';

class TeacherCreateNotice extends ConsumerStatefulWidget {
  final NoticeModel notice;
  const TeacherCreateNotice({super.key, required this.notice});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TeacherCreateNoticeState();
}

class _TeacherCreateNoticeState extends ConsumerState<TeacherCreateNotice> {
  @override
  Widget build(BuildContext context) {
    final formNoticeNotifier = ref.read(noticesFormProvider.notifier);
    final formNotice = ref.watch(noticesFormProvider);
    NoticeModel notice = widget.notice;

    ref.listen(
      noticesFormProvider,
      (previous, next) {
        if (next.isFormPosted && !next.isPosting) {
          context.pop();
        }
      },
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Crear aviso',
      ),

      // ⬇️ BOTÓN "CREAR" MOVIDO ABAJO
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 25),
        child: CustomRoundedButton(
          text: 'Crear',
          onPressed: () async {
            if (formNotice.isPosting) return;

            await formNoticeNotifier.onFormSubmit(notice);
          },
        ),
      ),

// ... (resto de los imports y configuración previa igual)

body: Form(
        child: SingleChildScrollView( // Mantiene el scroll para evitar errores con el teclado
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alinea todo a la izquierda
            children: [
              
              // 1. NOMBRE DE LA MATERIA (Limpio)
              Text(
                widget.notice.subjectName ?? 'Materia General',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              // 2. Texto de ayuda
              const Text(
                'Redacta un nuevo aviso para tu materia.\n'
                'Puedes incluir texto, enlaces o archivos adjuntos para tus estudiantes.',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              // 3. Campos del formulario
              CustomTextFormField(
                label: 'Título', // Corregí "Titulo" a "Título"
                capitalizeFirstLetter: true,
                onChanged: formNoticeNotifier.onTitleChanged,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                label: 'Mensaje',
                capitalizeFirstLetter: true,
                enableLineBreak: true,
                onChanged: formNoticeNotifier.onDescriptionChanged,
              ),
            ],
          ),
        ),
      ),
// ... (resto del archivo igual)

    );
  }
}

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25 / 2.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                leading ??
                    Transform.translate(
                      offset: const Offset(-14, 0),
                      child: BackButton(
                        color: Colors.black,
                        onPressed: () => context.pop(),
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 80);
}
