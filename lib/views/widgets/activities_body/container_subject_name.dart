//import 'package:aprende_mas/config/utils/app_theme.dart';
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
    return CustomContainerStyle(
      height: context.height(0.25), // 25% de la altura de pantalla
      width: double.infinity,
      color: color,
      child: Stack(
        children: [
          // Flecha de regresar dentro del container
          Positioned(
            top: context.height(0.04), // 4% de la altura
            left: context.width(0.04), // 4% del ancho
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: SvgPicture.asset('assets/icons/retroceder.svg', width: 35, height: 35, color: Colors.white),
              tooltip: 'Regresar',
            ),
          ),
          // Título y código abajo izquierda (siempre visible y alternativo si no hay código)
          Positioned(
            left: context.width(0.06), // 6% del ancho
            right: context.width(0.06), // 6% del ancho (sin espacio para el botón de ajustes)
            bottom: context.height(0.025), // 2.5% de la altura
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.fontSize(24), // Tamaño base 24, escalado responsive
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // Evita overflow
                ),
                Padding(
                  padding: EdgeInsets.only(top: context.height(0.01)), // 1% de la altura
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Solo ocupar el espacio necesario
                    children: [
                      Text(
                        'Código de clase: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.fontSize(18), // Tamaño base 18, escalado responsive
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Expanded( // Permitir que el código se expanda
                        child: Text(
                          (accessCode != null && accessCode!.isNotEmpty)
                            ? accessCode!
                            : 'Sin código',
                          style: TextStyle(
                            color: (accessCode != null && accessCode!.isNotEmpty)
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                            fontSize: context.fontSize(18), // Tamaño base 18, escalado responsive
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Botón de ajustes circular arriba derecha
          Positioned(
            top: context.height(0.06),
            right: context.width(0.07),
            child: GestureDetector(
              onTap: () {},
              child: SvgPicture.asset('assets/icons/settings2.svg', width: 50, height: 50, color: Colors.white,),
              /*
              child: CircleAvatar(
                radius: context.radius(0.07), // 7% del ancho
                backgroundColor: Colors.white,
                child: SvgPicture.asset('assets/icons/settings2.svg', width: 35, height: 35, color: Colors.blue[900],),
              ),
              */
            ),
          ),
        ],
      ),
    );
  }
}

