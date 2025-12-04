import 'package:aprende_mas/views/widgets/cards/subject_card.dart';
import '../../../config/utils/packages.dart';
import 'package:aprende_mas/providers/providers.dart';

class SubjectsWithoutGroupsContainer extends ConsumerStatefulWidget {
  const SubjectsWithoutGroupsContainer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SubjectsWithoutGroupsContainerState();
}

class _SubjectsWithoutGroupsContainerState
    extends ConsumerState<SubjectsWithoutGroupsContainer> {
  // 1. CONTROLADOR DE BÚSQUEDA
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  Color stringToColor(String hexColor) {
    Color colorCode = Color(int.parse("0xFF$hexColor"));
    return colorCode;
  }

  @override
  void initState() {
    super.initState();

    // 2. LISTENER: Actualiza la variable _searchTerm cada vez que escribes
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider).lsSubjects;

    // 3. FILTRADO LOCAL: Filtramos la lista 'subjects' aquí mismo
    final filteredSubjects = subjects.where((element) {
      final titleLower = element.nombreMateria.toLowerCase();
      final descLower = (element.descripcion ?? "").toLowerCase();
      final searchLower = _searchTerm.toLowerCase();

      return titleLower.contains(searchLower) ||
             descLower.contains(searchLower);
    }).toList();

    return Column(
      children: [
        // Campo de búsqueda (si hay materias)
        if (subjects.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar materias',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),

        // Contenido principal
        Expanded(
          child: subjects.isEmpty
              ? const Center(
                  child: Text('No hay materias disponibles.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                  ),
                )
              : filteredSubjects.isEmpty
                  ? const Center(
                      child: Text('No se encontraron materias con esa búsqueda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = filteredSubjects[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SubjectCard(
                            subjectId: subject.materiaId,
                            nombreMateria: subject.nombreMateria,
                            description: subject.descripcion ?? "",
                            accessCode: subject.codigoAcceso ?? "",
                            actividades: subject.actividades,
                            widthFactor: 0.96,
                            heightFactor: 0.14,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
