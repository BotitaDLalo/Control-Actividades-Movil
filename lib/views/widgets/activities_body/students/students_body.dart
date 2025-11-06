import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/widgets/activities_body/custom_container_style.dart';

class StudentsBody extends ConsumerWidget {
  const StudentsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomContainerStyle(
        height: 60,
        width: double.infinity,
        color: Colors.white,
        borderColor: Colors.blue,
        child: Row(
          children: [
            const SizedBox(width: 10,),
            const Icon(Icons.person),
            const SizedBox(width: 20,),
            const Text('Nombre del alumno'),
            const SizedBox(width: 10,),
            IconButton(onPressed: () {}, icon: const Icon(Icons.mail))
          ],
        ),
      ),
    );
  }
}
