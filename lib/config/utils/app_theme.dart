import 'package:aprende_mas/config/utils/packages.dart';
import 'package:flutter/material.dart';

const List<Color> _colorThemes = [
  Color.fromARGB(255, 255, 255, 255), //$White 0
  Color.fromARGB(255, 52, 115, 250), //$Blue 1
  Color.fromARGB(255, 0, 0, 0), //$ Black 2
  Color.fromARGB(100, 0, 0, 0), //$Negro palido 3
  Color.fromARGB(150, 0, 0, 0), //$Negro palido 4
  Color.fromARGB(140, 141, 141, 141), //$ Gris 5
  Color(0xFFCDDC39) //# Principal verde limón
];

class AppTheme {
  // final Color buttonColor = _colorThemes[1];

  static Color mainColor = _colorThemes[6];
  // static Color secondMainColor =Colors.yellow[700]!;

  static final Color isSelectedGroup = _colorThemes[1];
  static final Color notSelectedGroup = _colorThemes[6];
  static final Color cardHeader = _colorThemes[5];

  static final Color pickedColor = _colorThemes[0];
  static final BorderRadius borderRadius = BorderRadius.circular(10);

//#Color picker availableColors
  static final List<Color> availableColors = [
    const Color(0xFF00BCD4),
    const Color(0xFF3F51B5),
    const Color(0xFF673AB7),
    const Color(0xFF9C27B0),
    const Color(0xFF009688),
    const Color(0xFF4CAF50),
    const Color(0xFF8BC34A),
    const Color(0xFFE91E63),
    const Color(0xFFF44336),
    const Color(0xFFFF5722),
    const Color(0xFFFF9800),
    const Color(0xFFFFC107),
  ];

//#Text theme style
  final TextTheme textThemes = TextTheme(
    titleLarge: const TextStyle(
        fontSize: 22, color: Colors.black, fontWeight: FontWeight.w500),
    bodyLarge: const TextStyle(
      fontSize: 22,
      color: Colors.black,
    ),
    bodyMedium: const TextStyle(fontSize: 20, color: Colors.black),
    bodySmall: TextStyle(fontSize: 15, color: Colors.grey[700]),
    // labelLarge: TextStyle(fontSize: 20, color: Colors.black)
  );

//#Degradated general
  static const LinearGradient degradedBlue = LinearGradient(
    colors: [
      Color.fromARGB(255, 52, 115, 250), // Color base
      Color.fromARGB(255, 84, 171, 250), // Color base
    ],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  //#Color picker box style
  static final BoxDecoration colorPickerBox = BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color.fromARGB(120, 0, 0, 0)),
      borderRadius: borderRadius);

//#Buttons styles
  static final ButtonStyle buttonPrimary = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0d6efd),
    // textStyle: const TextStyle(fontSize: 16),
    fixedSize: const Size.fromHeight(45),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadius, // border radius
    ),
  );

  static final ButtonStyle buttonSecondary = ElevatedButton.styleFrom(
    backgroundColor: _colorThemes[0],
    // textStyle: const TextStyle(fontSize: 16),
    foregroundColor: _colorThemes[2],
    // fixedSize: const Size.fromHeight(45),
    // side: BorderSide(color: _colorThemes[1]),
    side: BorderSide(color: _colorThemes[3]),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadius, // border radius
    ),
  );

  static final ButtonStyle buttonTertiary = ElevatedButton.styleFrom(
    backgroundColor: _colorThemes[0],
    foregroundColor: _colorThemes[4],
    // textStyle: const TextStyle(fontSize: 16),
    fixedSize: const Size.fromHeight(35),
    side: BorderSide(color: _colorThemes[3]),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50), // border radius
    ),
  );

  static Color stringToColor(String hexColor) {
    Color colorCode = Color(int.parse("0xFF$hexColor"));
    return colorCode;
  }

  static RoundedRectangleBorder shapeFloatingActionButton() =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      );

  ThemeData theme() {
    return ThemeData(
        textTheme: textThemes, scaffoldBackgroundColor: _colorThemes[0]);
  }
}
