import 'package:aprende_mas/config/utils/packages.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CatalogButtonNavigationBarItems {
  static List<BottomNavigationBarItem> lsBarItems = [
    BottomNavigationBarItem(
      icon: SvgPicture.asset(
        'assets/icons/calendar1.svg',
        width: 24,
        height: 24,
      ),
      label: 'Agenda',
    ),
    BottomNavigationBarItem(
      icon: SvgPicture.asset(
        'assets/icons/studentcap1.svg',
        width: 24,
        height: 24,
      ),
      label: 'Clases',
    ),
    BottomNavigationBarItem(
      icon: SvgPicture.asset(
        'assets/icons/notificaciones3.svg',
        width: 24,
        height: 24,
      ),
      label: 'Notificaciones',
    ),
    BottomNavigationBarItem(
      icon: SvgPicture.asset(
        'assets/icons/chat1.svg',
        width: 24,
        height: 24,
      ),
      label: 'Chat IA',
    ),
  ];
}
