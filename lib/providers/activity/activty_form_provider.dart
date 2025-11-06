import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/providers/activity/activity_form_notifier.dart';
import 'package:aprende_mas/providers/activity/activity_form_state.dart';
import 'package:aprende_mas/providers/activity/activity_provider.dart';

final activityFormProvider =
    StateNotifierProvider.autoDispose<ActivityFormNotifier, ActivityFormState>(
  (ref) {
    // Cambiamos a activityProvider.notifier
    final createActivity = ref.read(activityProvider.notifier).createdActivity;
    final sendActivity = ref.read(activityProvider.notifier).sendSubmission;
    final sendActivityOffline =
        ref.read(activityProvider.notifier).sendSubmissionOffline;
    final submissionGrading =
        ref.read(activityProvider.notifier).submissionGrading;

    return ActivityFormNotifier(
        submissionGradingCallback: submissionGrading,
        activityCallback: createActivity,
        sendSubmissionCallback: sendActivity,
        sendSubmissionOfflineCallback: sendActivityOffline);
  },
);
