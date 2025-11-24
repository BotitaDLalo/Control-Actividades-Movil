import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/agenda/form_event_provider.dart';
import 'package:aprende_mas/providers/providers.dart';

class OptionDropdownForm extends ConsumerStatefulWidget {
  const OptionDropdownForm({super.key});

  @override
  ConsumerState<OptionDropdownForm> createState() => _OptionDropdownFormState();
}

class _OptionDropdownFormState extends ConsumerState<OptionDropdownForm> {
  String? _selectedType;
  int? _selectedItemId;
  List<Map<String, dynamic>> _options = [];

  @override
  void initState() {
    super.initState();
    ref.read(groupsProvider.notifier).getGroupsSubjects();
    ref.read(subjectsProvider.notifier).getSubjects();
  }

  void _updateOptions(String selectedType) {
    if (!mounted) return;

    setState(() {
      _selectedType = selectedType;
      _selectedItemId = null;

      if (_selectedType == 'Grupo') {
        final groupsState = ref.watch(groupsProvider);
        _options = groupsState.lsGroups.map((group) => {
              'id': group.grupoId.toString(),
              'name': group.nombreGrupo,
            }).toList();
      } else if (_selectedType == 'Materia') {
        final subjectsState = ref.watch(subjectsProvider);
        _options = subjectsState.lsSubjects.map((subject) => {
              'id': subject.materiaId.toString(),
              'name': subject.nombreMateria,
            }).toList();
      }
    });
  }

  void _onItemSelected(int? value) {
  if (value == null) return;
  
  setState(() {
    _selectedItemId = value;
  });

  final formEventNotifier = ref.read(formEventProvider.notifier);

  if (_selectedType == 'Grupo') {
    formEventNotifier.onGroupIdsChanged([value]);

    // Asignar color por defecto al seleccionar un grupo
    formEventNotifier.onColorCodeChanged(Colors.blue);
  } else if (_selectedType == 'Materia') {
    formEventNotifier.onSubjectIdsChanged([value]);

    // Asignar color por defecto al seleccionar una materia
    formEventNotifier.onColorCodeChanged(Colors.grey);
  }
}


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
                labelText: 'Tipo',
                // use global theme (underline) instead of forcing outline
                isDense: true,
              ),
            items: ['Grupo', 'Materia']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type, style: const TextStyle(color: Colors.black87)),
                    ))
                .toList(),
            value: _selectedType,
            onChanged: (value) {
              if (value != null) {
                _updateOptions(value);
              }
            },
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          flex: 2,
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: _selectedType == null
                  ? 'Seleccione un tipo primero'
                  : 'Seleccione ${_selectedType!.toLowerCase()}',
              isDense: true,
            ),
            items: _options.isEmpty
                ? []
                : _options.map((option) {
                    return DropdownMenuItem(
                      value: int.parse(option['id']),
                      child: Text(option['name'], style: const TextStyle(color: Colors.black87)),
                    );
                  }).toList(),
            value: _selectedItemId,
            onChanged: _options.isNotEmpty ? _onItemSelected : null,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
