import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/teacher/groups/form_create_group.dart';
import 'package:aprende_mas/views/widgets/structure/form_screen.dart';

class CreateGroupScreen extends ConsumerWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const FormScreen(
      form: FormCreateGroup(),
      title: 'Crear grupo',
    );
  }
}
