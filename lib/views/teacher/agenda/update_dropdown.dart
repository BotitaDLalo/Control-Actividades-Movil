import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/agenda/event_model.dart';
import 'package:aprende_mas/providers/agenda/form_event_provider.dart';
import 'package:aprende_mas/providers/agenda/form_update_event_provider.dart';
import 'package:aprende_mas/providers/groups/groups_provider.dart';
import 'package:aprende_mas/providers/subjects/subjects_provider.dart';

class UpdateDropdownForm extends ConsumerStatefulWidget {
  final Event event;
  final int? initialItemId;
  final bool isGroup;

  const UpdateDropdownForm({
    super.key,
    required this.isGroup,
    this.initialItemId,
    required this.event,
  });

  @override
  ConsumerState<UpdateDropdownForm> createState() => _OptionDropdownFormState();
}

class _OptionDropdownFormState extends ConsumerState<UpdateDropdownForm> {
  int? _selectedItemId;
  late bool _isGroup;

  @override
void initState() {
  super.initState();
  _isGroup = widget.isGroup;
  _selectedItemId = widget.initialItemId; // Asignamos el valor inicial directamente
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    final groupsNotifier = ref.read(groupsProvider.notifier);
    final subjectsNotifier = ref.read(subjectsProvider.notifier);

    if (_isGroup && ref.read(groupsProvider).lsGroups.isEmpty) {
      groupsNotifier.getGroupsSubjects();
    }
    if (!_isGroup && ref.read(subjectsProvider).lsSubjects.isEmpty) {
      subjectsNotifier.getSubjects();
    }
  });
}


  void _onItemSelected(int? value) {
    if (value == null || !mounted) return;

    setState(() {
      _selectedItemId = value;
    });

    final formEventNotifier = ref.read(formUpdateEventProvider(widget.event).notifier);
    if (!mounted) return;

    if (_isGroup) {
      formEventNotifier.onUpdateGroupIdsChanged([value]);
      formEventNotifier.onUpdateGroupColorChanged(const Color(0xFF2196F3));
       print("Asignando color azul para grupo");
    } else {
      formEventNotifier.onUpdateSubjectIdsChanged([value]);
      formEventNotifier.onUpdateGroupColorChanged(Colors.green);
    }
  }

  void _onTypeChanged(String? newValue) {
    if (newValue == null || !mounted) return;

    setState(() {
      _isGroup = newValue == 'Grupo';
      _selectedItemId = null;
    });

    final groupsNotifier = ref.read(groupsProvider.notifier);
    final subjectsNotifier = ref.read(subjectsProvider.notifier);

    if (_isGroup && ref.read(groupsProvider).lsGroups.isEmpty) {
      groupsNotifier.getGroupsSubjects();
    }
    if (!_isGroup && ref.read(subjectsProvider).lsSubjects.isEmpty) {
      subjectsNotifier.getSubjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsState = ref.watch(groupsProvider.select((state) => state.lsGroups));
    final subjectsState = ref.watch(subjectsProvider.select((state) => state.lsSubjects));

    final options = _isGroup
        ? groupsState.map((group) => DropdownMenuItem<int>(
              value: group.grupoId,
              child: Text(group.nombreGrupo),
            )).toList()
        : subjectsState.map((subject) => DropdownMenuItem<int>(
              value: subject.materiaId,
              child: Text(subject.nombreMateria),
            )).toList();

    if (_selectedItemId == null && widget.initialItemId != null) {
      final existsInOptions = options.any((option) => option.value == widget.initialItemId);
      if (existsInOptions) {
        _selectedItemId = widget.initialItemId;
      }
    }

    return Row(
      children: [
        Flexible(
          flex: 2,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Tipo',
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 'Grupo', child: Text('Grupo')),
              DropdownMenuItem(value: 'Materia', child: Text('Materia')),
            ],
            value: _isGroup ? 'Grupo' : 'Materia',
            onChanged: _onTypeChanged,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 2,
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: _isGroup ? 'Grupo' : 'Materia',
              isDense: true,
            ),
            items: options,
            value: _selectedItemId,
            onChanged: _onItemSelected,
          ),
        ),
      ],
    );
  }
}
