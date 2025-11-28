import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/groups/group.dart';
import 'package:aprende_mas/config/utils/utils.dart';
import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/providers/groups/groups_provider.dart';
import 'package:aprende_mas/providers/data/key_value_storage_service_providers.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';

class GroupCard extends ConsumerStatefulWidget {
  final int id;
  final String title;
  final Color color;
  final String description;
  final String? accessCode;
  final List<Widget> children;
  final Duration animationDuration;

  const GroupCard(
      {super.key,
      required this.id,
      required this.title,
      required this.color,
      required this.description,
      required this.children,
      this.accessCode,
      this.animationDuration = const Duration(milliseconds: 600)});

  @override
  CustomExpansionTileState createState() => CustomExpansionTileState();
}

class CustomExpansionTileState extends ConsumerState<GroupCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;
  final cn = CatalogNames();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward(); // Expande
      } else {
        _controller.reverse(); // Contrae
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, Group groupData) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('Eliminar grupo'),
         content: const Text('¿Estás seguro de que deseas eliminar este grupo? Esta acción no se puede deshacer.'),
         actions: [
           TextButton(
             onPressed: () => Navigator.of(context).pop(),
             child: const Text('Cancelar'),
           ),
           TextButton(
             onPressed: () async {
               Navigator.of(context).pop();
               bool success = await ref.read(groupsProvider.notifier).deleteGroup(groupData.grupoId!);
               if (!success) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('No se eliminó el grupo')),
                 );
               }
             },
             child: const Text('Eliminar'),
           ),
         ],
       ),
     );
   }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyValueStorageService = KeyValueStorageServiceImpl();
    final cn = ref.watch(catalogNamesProvider);
    final role = ref.watch(roleFutureProvider).maybeWhen(
      data: (data) => data,
      orElse: () => "",
    );

    void pushGroupTeacherSettings(Group data) {
      context.push('/group-teacher-settings', extra: data);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: AnimatedSize(
        duration: widget.animationDuration,
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            // cuando está colapsado usamos un gradiente basado en el color proporcionado
            gradient: _isExpanded
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color,
                      Color.lerp(widget.color, const Color.fromARGB(255, 255, 255, 255), 0.25) ?? widget.color,
                    ],
                  ),
            // cuando está expandido usamos un color de fondo más claro
            color: _isExpanded ? widget.color.withOpacity(0.70) : null,
            borderRadius: BorderRadius.circular(_isExpanded ? 15 : 20),
            border: Border.all(
              color: const Color.fromARGB(255, 6, 179, 226),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_isExpanded ? 15 : 20),
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Watermark en la esquina inferior izquierda
                  Positioned(
                    right: 20,
                    bottom: -10,
                    child: Opacity(
                      opacity: 0.30,
                      child: SvgPicture.asset(
                        'assets/icons/grupo2.svg',
                        width: 100,
                        height: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Contenido
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Material(
                        color: const Color.fromARGB(0, 220, 14, 203),
                        child: InkWell(
                          onTap: _toggleExpand,
                          borderRadius: BorderRadius.circular(19),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 255, 255, 255),
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.description,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color.fromARGB(253, 183, 242, 251),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (role == cn.getRoleTeacherName)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 28,
                                        color: Color.fromARGB(221, 255, 255, 255),
                                      ),
                                      onSelected: (value) {
                                        final Group groupData = Group(
                                          grupoId: widget.id,
                                          nombreGrupo: widget.title,
                                          descripcion: widget.description,
                                          codigoAcceso: widget.accessCode,
                                        );
                                        if (value == 'edit') {
                                          pushGroupTeacherSettings(groupData);
                                        } else if (value == 'delete') {
                                          _showDeleteConfirmation(context, groupData);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Editar'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  const SizedBox(width: 12),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Linea que divide el encabezado del contenido en la card desplegada
                      if (_isExpanded) ...[
                        const Divider(height: 1, color: Color.fromARGB(255, 255, 255, 255)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children: widget.children),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
