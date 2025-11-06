import 'package:aprende_mas/views/views.dart';
// import 'package:aprende_mas/views/widgets/forms/form_forgot_password.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.pop();
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: const SingleChildScrollView(
          // physics: const ClampingScrollPhysics(),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FormForgotPassword()
            ],
          ),
        ),
      ),
    );
  
  }
}
