import 'package:flutter/material.dart';

class NoInternetSnackBar {
  static bool _isShowing = false;

  static void show(BuildContext context) {
    if (_isShowing) return;
    _isShowing = true;

    ScaffoldMessenger.of(context)
        .showSnackBar(
          const SnackBar(
            content: Text('No hay conexión a internet'),
            backgroundColor: Colors.black,
            duration: Duration(days: 1),
          ),
        )
        .closed
        .then((_) => _isShowing = false);
  }

  static void hide(BuildContext context) {
    if (!_isShowing) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    _isShowing = false;
  }
}
