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
      padding: ResponsiveUtils.margin(context, horizontal: 0.04, vertical: 0.013), // 4% horizontal, 1.3% vertical
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
            borderRadius: BorderRadius.circular(_isExpanded ? context.radius(0.04) : context.radius(0.055)), // 4% o 5.5%
            border: Border.all(
              color: const Color.fromARGB(255, 6, 179, 226),
              width: context.width(0.005), // 0.5% del ancho
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_isExpanded ? context.radius(0.04) : context.radius(0.055)),
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Watermark en la esquina inferior izquierda
                  Positioned(
                    right: context.width(0.05), // 5% del ancho
                    bottom: -context.height(0.013), // 1.3% del alto (negativo)
                    child: Opacity(
                      opacity: 0.30,
                      child: SvgPicture.asset(
                        'assets/icons/grupo2.svg',
                        width: context.width(0.25), // 25% del ancho
                        height: context.width(0.25), // 25% del ancho (mantiene proporción)
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
                          borderRadius: BorderRadius.circular(context.radius(0.052)), // 5.2%
                          child: SizedBox(
                            height: context.height(0.1), // 10% del alto
                            child: Row(
                              children: [
                                SizedBox(width: context.width(0.03)), // 3% del ancho
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: const Color.fromARGB(255, 255, 255, 255),
                                          fontSize: context.fontSize(21), // Tamaño base 21, escalado responsive
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: context.height(0.005)), // 0.5% del alto
                                      Text(
                                        widget.description,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: const Color.fromARGB(253, 183, 242, 251),
                                          fontSize: context.fontSize(15), // Tamaño base 15, escalado responsive
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (role == cn.getRoleTeacherName)
                                  Padding(
                                    padding: EdgeInsets.only(right: context.width(0.03)), // 3% del ancho
                                    child: PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert,
                                        size: context.width(0.075), // 7.5% del ancho
                                        color: const Color.fromARGB(221, 255, 255, 255),
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
                                  SizedBox(width: context.width(0.03)), // 3% del ancho
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Linea que divide el encabezado del contenido en la card desplegada
                      if (_isExpanded) ...[
                        const Divider(height: 1, color: Color.fromARGB(255, 255, 255, 255)),
                        Padding(
                          padding: EdgeInsets.all(context.width(0.02)), // 2% del ancho en todos los lados
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
