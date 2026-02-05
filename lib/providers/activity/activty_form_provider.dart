import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/activity/activity_form_notifier.dart';
import 'package:aprende_mas/providers/activity/activity_form_state.dart';
import 'package:aprende_mas/providers/activity/activity_provider.dart';

final activityFormProvider =
    StateNotifierProvider.autoDispose<ActivityFormNotifier, ActivityFormState>(
  (ref) {
    final activityNotifier = ref.read(activityProvider.notifier);

    final createActivity = activityNotifier.createdActivity;
    final sendActivity = activityNotifier.sendSubmission;
    final sendActivityWithLinks = activityNotifier.sendSubmissionWithLinks;
    final sendActivityWithFiles = activityNotifier.sendSubmissionWithFiles;
    final sendActivityWithFilesAndLinks = activityNotifier.sendSubmissionWithFilesAndLinks;
    final sendActivityOffline = activityNotifier.sendSubmissionOffline;
    final submissionGrading = activityNotifier.submissionGrading;
    final uploadFile = activityNotifier.uploadFile;
    final updateActivity = activityNotifier.updateActivity;

    return ActivityFormNotifier(
        submissionGradingCallback: submissionGrading,
        activityCallback: createActivity,
        updateActivityCallback: updateActivity,
        sendSubmissionCallback: sendActivity,
        sendSubmissionWithLinksCallback: sendActivityWithLinks,
        sendSubmissionWithFilesCallback: sendActivityWithFiles,
        sendSubmissionWithFilesAndLinksCallback: sendActivityWithFilesAndLinks,
        sendSubmissionOfflineCallback: sendActivityOffline,
        uploadFileCallback: uploadFile,
    );
  },
);
