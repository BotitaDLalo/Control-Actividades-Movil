import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';


class FloatingActionButtonCustom extends ConsumerWidget {
  final Function()? voidCallback;
  final IconData icon;
  final Color? backgroundColor;
  const FloatingActionButtonCustom(
      {super.key, required this.voidCallback, required this.icon, this.backgroundColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final bgColor = backgroundColor ?? AppTheme.mainColor;
    final iconColor = bgColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return FloatingActionButton(
      onPressed: voidCallback,
      backgroundColor: bgColor,
      shape: AppTheme.shapeFloatingActionButton(),
      child: Icon(
        icon,
        color: iconColor,
      ),
    );
  }
}
