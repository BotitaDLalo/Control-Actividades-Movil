import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/structure/app_bar_home.dart';
// import 'package:aprende_mas/views/widgets/forms/form_forgot_password.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBarHome(title: 'Recuperar contraseña', showSettings: false, titleFontSize: 21,),
        body: SingleChildScrollView(
          child: Column(
            children: const [FormForgotPassword()],
          ),
        ),
      ),
    );
  
  }
}
