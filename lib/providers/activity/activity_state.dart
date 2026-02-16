import 'package:aprende_mas/models/activities/activity/activity.dart';
import 'package:aprende_mas/models/models.dart';

class ActivityState {
  final List<Activity> lsActivities; // Lista de actividades cargadas
  final bool isLoading; // Indica si las actividades están cargándose
  final String? errorMessage; // Mensaje de error en caso de fallo
  final String answer;
  final double grade;
  final List<Submission> lsSubmissions;

  ActivityState(
      {this.lsActivities = const [],
      this.isLoading = false,
      this.grade = 0.0,
      this.errorMessage,
      this.lsSubmissions = const [],
      this.answer = ""});

  ActivityState copyWith(
      {List<Activity>? lsActivities,
      bool? isLoading,
      String? errorMessage,
      String? answer,
      double? grade,
      List<Submission>? lsSubmissions}) {
    return ActivityState(
        lsActivities: lsActivities ?? this.lsActivities,
        grade: grade ?? this.grade,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        answer: answer ?? this.answer,
        lsSubmissions: lsSubmissions ?? this.lsSubmissions);
  }
}
