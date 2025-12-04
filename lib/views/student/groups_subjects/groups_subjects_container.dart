import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/widgets.dart';

class GroupsSubjectsContainer extends ConsumerStatefulWidget {
  const GroupsSubjectsContainer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupsSubjectsContainerState();
}

class _GroupsSubjectsContainerState
    extends ConsumerState<GroupsSubjectsContainer> {
  // 1. CONTROLADOR DE BÚSQUEDA
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

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
    final groups = ref.watch(groupsProvider).lsGroups;

    // 3. FILTRADO LOCAL: Filtramos la lista 'groups' aquí mismo
    final filteredGroups = groups.where((element) {
      final titleLower = element.nombreGrupo.toLowerCase();
      final descLower = (element.descripcion ?? "").toLowerCase();
      final searchLower = _searchTerm.toLowerCase();

      return titleLower.contains(searchLower) ||
             descLower.contains(searchLower);
    }).toList();

    return Column(
      children: [
        // Campo de búsqueda (si hay grupos)
        if (groups.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar grupos',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),

        // Contenido principal
        Expanded(
          child: groups.isEmpty
              ? const Center(
                  child: Text('No hay grupos disponibles.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                  ),
                )
              : filteredGroups.isEmpty
                  ? const Center(
                      child: Text('No se encontraron grupos con esa búsqueda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredGroups.length,
                      itemBuilder: (context, index) {
                        final grupo = filteredGroups[index];
                        return GroupCard(
                          id: grupo.grupoId ?? -1,
                          title: grupo.nombreGrupo,
                          description: grupo.descripcion ?? "",
                          accessCode: grupo.codigoAcceso,
                          color: AppTheme.mainColor,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SubjectScroll(
                                groupId: grupo.grupoId,
                                materias: grupo.materias,
                              ),
                            )
                          ],
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
