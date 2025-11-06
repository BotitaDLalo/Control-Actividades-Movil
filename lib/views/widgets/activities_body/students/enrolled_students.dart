import 'package:aprende_mas/views/widgets/activities_body/custom_container_style.dart';
import 'package:flutter/material.dart';

class EnrolledStudents extends StatelessWidget {
  const EnrolledStudents({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomContainerStyle(
      height: 30,
      width: double.infinity,
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 80),
        child: Text('Alumnos inscritos'),
      ),
    );
  }
}