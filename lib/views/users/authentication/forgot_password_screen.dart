import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/views/widgets/structure/app_bar_home.dart';
// import 'package:aprende_mas/views/widgets/forms/form_forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBarHome(title: 'Recuperar contraseña', showSettings: false, titleFontSize: 21, leading: IconButton(icon: SvgPicture.asset('assets/icons/retroceder.svg', width: 35, height: 35, color: Colors.white), onPressed: () => Navigator.pop(context))),
        body: SingleChildScrollView(
          child: Column(
            children: const [FormForgotPassword()],
          ),
        ),
      ),
    );
  
  }
}

