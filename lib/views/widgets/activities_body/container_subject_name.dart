import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'custom_container_style.dart';

class ContainerNameGroupSubjects extends StatelessWidget {
  final String name;
  final String? accessCode;
  final Color color;
  const ContainerNameGroupSubjects(
      {super.key, required this.name, this.accessCode, required this.color});

  @override
  Widget build(BuildContext context) {
    // Color color(String colorCode) {
    //   if (colorCode == "") {
    //     return AppTheme.cardHeader;
    //   } else {
    //     return AppTheme.stringToColor(colorCode);
    //   }
    // }

    return CustomContainerStyle(
      height: 90,
      width: double.infinity,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Text(
                    name,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis
                        ),
                  ),
                ),
                accessCode != null
                    ? Row(
                        children: [
                          const Text(
                            'Código de clase: ',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            accessCode ?? "",
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      )
                    : const SizedBox()
              ],
            ),
            const Spacer(),
            Row(
              children: [
                const VerticalDivider(
                  color: Colors.black, // Color del divider
                  thickness: 2, // Grosor del divider
                  width: 10, // Espacio antes y después del divider
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.black,
                      size: 40,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
