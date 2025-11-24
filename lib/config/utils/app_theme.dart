import 'package:aprende_mas/config/utils/packages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const List<Color> _colorThemes = [
  Color.fromARGB(255, 255, 255, 255), //$White 0
  Color.fromARGB(255, 52, 115, 250), //$Blue 1
  Color.fromARGB(255, 0, 0, 0), //$ Black 2
  Color.fromARGB(100, 0, 0, 0), //$Negro palido 3
  Color.fromARGB(150, 0, 0, 0), //$Negro palido 4
  Color.fromARGB(140, 141, 141, 141), //$ Gris 5
  Color.fromARGB(255, 33, 150, 243) //# Principal blue
];

class AppTheme {
  // final Color buttonColor = _colorThemes[1];

  static Color mainColor = _colorThemes[6];
  // static Color secondMainColor =Colors.yellow[700]!;

  static final Color isSelectedGroup = _colorThemes[1];
  static final Color notSelectedGroup = _colorThemes[6];
  static final Color cardHeader = _colorThemes[5];

  static final Color pickedColor = _colorThemes[0];
  static final BorderRadius borderRadius = BorderRadius.circular(30);

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
    backgroundColor: const Color.fromARGB(255, 15, 126, 217),
    //textStyle: const TextStyle(fontSize: 16),
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
    // Aplicar la tipografía Inter a toda la aplicación, respetando los estilos
    final base = ThemeData(scaffoldBackgroundColor: _colorThemes[0]);
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(textThemes),
      primaryTextTheme: GoogleFonts.interTextTheme(base.primaryTextTheme),
      // también aplicamos a los textos de widgets elevados y botones donde corresponda
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.inter(textStyle: textThemes.titleLarge),
      ),
      // Estilo global para todos los campos de texto: línea inferior (underline)
      inputDecorationTheme: InputDecorationTheme(
        
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIconColor: mainColor,
        suffixIconColor: Colors.grey[600],
        // Línea inferior por defecto
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.35)),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.35)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: mainColor, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red.withOpacity(0.9)),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red.withOpacity(0.9), width: 2),
        ),
      ),
      // Cursor y selección para campos de texto
      textSelectionTheme: TextSelectionThemeData(cursorColor: mainColor),
      // Hacer que los ElevatedButton usen por defecto el estilo de buttonPrimary
      elevatedButtonTheme: ElevatedButtonThemeData(style: buttonPrimary),
      // También proporcionar estilos coherentes para TextButton y OutlinedButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 15, 126, 217),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          minimumSize: const Size.fromHeight(45),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _colorThemes[2],
          backgroundColor: _colorThemes[0],
          side: BorderSide(color: _colorThemes[3]),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          minimumSize: const Size.fromHeight(45),
        ),
      ),
    );
  }
}
