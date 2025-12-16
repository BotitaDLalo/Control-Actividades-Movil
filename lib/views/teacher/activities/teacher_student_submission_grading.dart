import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/views.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/widgets/cards/element_card.dart';
import 'package:flutter/services.dart';
import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/alerts/success_dialog.dart';
import 'package:aprende_mas/views/widgets/alerts/error_dialog.dart';

class TeacherStudentSubmissionGrading extends ConsumerStatefulWidget {
  final TeacherStudentSubmissionGradingModel data;
  const TeacherStudentSubmissionGrading({super.key, required this.data});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TeacherStudentSubmissionGradingState();
}

class _TeacherStudentSubmissionGradingState
    extends ConsumerState<TeacherStudentSubmissionGrading> {
  final gradeController = TextEditingController();

  @override
  void dispose() {
    gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final submissionId = data.submissionId;
    final userName = data.userName;
    final fullName = data.fullName;
    final answer = data.answer;
    final score = data.score;

    final activity = ref.watch(activityProvider);
    final activityNotifier = ref.read(activityProvider.notifier);

    final activityForm = ref.watch(activityFormProvider);
    final activityFormNotifier = ref.read(activityFormProvider.notifier);

    hideSnackBar() {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    showSuccessMessage(String message) {
      hideSnackBar();
      SuccessDialog.show(context, message: message);
    }

    showErrorMessage(String message) {
      hideSnackBar();
      ErrorDialog.show(context, message: message);
    }

    closeKeyboard() {
      // FocusScope.of(context).unfocus();
      gradeController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        elevation: 0,
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/retroceder.svg', width: 30, height: 30, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '',
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElementTile(
                icon: Icons.person,
                iconColor: Colors.white,
                iconSize: 36,
                title: userName,
                subtitle: fullName),
            ElementCard(
              answer: answer,
              score: score,
              grade: activity.grade,
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.only(left: 8,right: 8,bottom: 18, top: 8),
        child: Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  activityFormNotifier.onSubmissionGradeChanged(value);
                },
                keyboardType: TextInputType.number,
                controller: gradeController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (activityForm.isPosting) {
                    return;
                  }
                  final submitedGraded = await ref
                      .read(activityFormProvider.notifier)
                      .onSubmitGrade(submissionId);

                  if (submitedGraded.isValid) {
                    if (submitedGraded.success) {
                      showSuccessMessage('Se asignó la calificación.');

                      activityNotifier.setSubmissionGrade(
                          int.parse(activityForm.newGrade.value));
                    } else {
                      showErrorMessage('Ocurrio un error');
                    }
                    closeKeyboard();
                  }
                },
                style: AppTheme.buttonSecondary,
                child: const Text('Asignar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
