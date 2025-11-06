import 'package:aprende_mas/config/utils/packages.dart';

class ElementTile extends ConsumerWidget {
  // final Notice notification;
  final String title;
  final String subtitle;
  final IconData icon;
  final IconData? trailingIcon;
  final String? trailingString;
  final Color iconColor;
  final Color? trailingColor;
  final double iconSize;
  final GestureTapCallback? onTapFunction;
  final VoidCallback? trailingVoidCallback;

  const ElementTile({
    super.key,
    required this.icon,
    required this.iconColor,
    this.trailingColor,
    this.trailingString,
    required this.iconSize,
    required this.title,
    required this.subtitle,
    this.onTapFunction,
    this.trailingVoidCallback,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: const BoxDecoration(
            // color: const Color.fromARGB(10, 0, 0, 0),
            // border: Border.all(color: const Color.fromARGB(28, 0, 0, 0), width: 1.0),
            // borderRadius: BorderRadius.circular(12),
            ),
        child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              radius: 22,
              child: Icon(icon, color: iconColor, size: iconSize),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  overflow: TextOverflow.ellipsis),
            ),
            trailing: trailingIcon != null
                ? IconButton(
                    onPressed: trailingVoidCallback,
                    icon: Icon(
                      trailingIcon,
                      color: trailingColor,
                      size: 25,
                    ))
                : Text(
                    trailingString ?? "",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
            onTap: onTapFunction),
      ),
    );
  }
}