import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/groups/group.dart';
import 'package:aprende_mas/config/utils/utils.dart';
import 'package:aprende_mas/config/data/data.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyValueStorageService = KeyValueStorageServiceImpl();
    final Color textColor = widget.color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    void pushGroupTeacherSettings(Group data) {
      context.push('/group-teacher-settings', extra: data);
    }
    
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.1,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              color: widget.color,
              child: Center(
                child: ListTile(
                  leading: SvgPicture.asset(
                    "assets/icons/grupo.svg",
                    height: 40,
                    width: 40,
                    colorFilter: ColorFilter.mode(
                      textColor, // color según contraste
                      BlendMode.srcIn,
                    ),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.all(6.5),
                    child: Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                  trailing: GestureDetector(
                    child: Icon(
                      Icons.settings,
                      // icon color adapted to background
                      color: textColor,
                      size: 35,
                    ),
                    onTap: () async {
                      final data = Group(
                          grupoId: widget.id,
                          nombreGrupo: widget.title,
                          descripcion: widget.description,
                          codigoAcceso: widget.accessCode ?? "",);

                      final role = await keyValueStorageService.getRole();

                      if (role == cn.getRoleTeacherName) {
                        pushGroupTeacherSettings(data);
                      } else if (role == cn.getRoleStudentName) {
                        // pushGroupStudentSettings(data);
                      }
                    },
                  ),
                  onTap: _toggleExpand, // Expande/contrae con un solo toque
                ),
              ),
            ),
          ),
        ),
        // Usa AnimatedSize para suavizar la transición de tamaño
        AnimatedSize(
          duration: widget.animationDuration,
          //Curves.ease
          //Curves.easeOutCubic
          curve: Curves.decelerate,
          child: _isExpanded
              ? Column(
                  children: widget.children,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
