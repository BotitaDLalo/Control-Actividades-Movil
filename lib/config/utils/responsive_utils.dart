import 'package:flutter/material.dart';

/// Utilidades para diseño responsive
/// Proporciona métodos para calcular tamaños basados en porcentajes de pantalla
class ResponsiveUtils {
  /// Obtiene el ancho de pantalla como porcentaje
  static double width(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  /// Obtiene el alto de pantalla como porcentaje
  static double height(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  /// Calcula el tamaño de fuente responsive
  /// Base: iPhone 6/7/8 (375px ancho)
  static double fontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    return baseSize * (screenWidth / 375.0);
  }

  /// Calcula el radio responsive para círculos/avatares
  static double radius(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  /// Calcula el padding responsive
  static EdgeInsets padding(BuildContext context,
      {double horizontal = 0.04, double vertical = 0.02}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return EdgeInsets.symmetric(
      horizontal: screenWidth * horizontal,
      vertical: screenHeight * vertical,
    );
  }

  /// Calcula el margen responsive
  static EdgeInsets margin(BuildContext context,
      {double horizontal = 0.04, double vertical = 0.02}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return EdgeInsets.symmetric(
      horizontal: screenWidth * horizontal,
      vertical: screenHeight * vertical,
    );
  }

  /// Determina el tipo de dispositivo basado en el ancho
  static DeviceType getDeviceType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return DeviceType.mobile;
    if (width < 1200) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Verifica si es un dispositivo móvil
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Verifica si es una tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Verifica si es desktop/web
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }
}

/// Tipos de dispositivo para responsive design
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Extensiones útiles para responsive design
extension ResponsiveExtensions on BuildContext {
  /// Ancho de pantalla como porcentaje
  double width(double percentage) => ResponsiveUtils.width(this, percentage);

  /// Alto de pantalla como porcentaje
  double height(double percentage) => ResponsiveUtils.height(this, percentage);

  /// Tamaño de fuente responsive
  double fontSize(double baseSize) => ResponsiveUtils.fontSize(this, baseSize);

  /// Radio responsive
  double radius(double percentage) => ResponsiveUtils.radius(this, percentage);

  /// Tipo de dispositivo
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);

  /// Es móvil
  bool get isMobile => ResponsiveUtils.isMobile(this);

  /// Es tablet
  bool get isTablet => ResponsiveUtils.isTablet(this);

  /// Es desktop
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
}