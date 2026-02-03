import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/activity/activity_form_notifier.dart';
import 'package:aprende_mas/providers/activity/activity_form_state.dart';
import 'package:aprende_mas/providers/activity/activity_provider.dart';

final activityFormProvider =
    StateNotifierProvider.autoDispose<ActivityFormNotifier, ActivityFormState>(
  (ref) {
    // Obtenemos el notificador principal
    final activityNotifier = ref.read(activityProvider.notifier);

    // Extraemos las funciones necesarias
    final createActivity = activityNotifier.createdActivity;
    final sendActivity = activityNotifier.sendSubmission;
    final sendActivityWithLinks = activityNotifier.sendSubmissionWithLinks;
    final sendActivityWithFiles = activityNotifier.sendSubmissionWithFiles; // Nuevo
    final sendActivityOffline = activityNotifier.sendSubmissionOffline;
    final submissionGrading = activityNotifier.submissionGrading;
    final uploadFile = activityNotifier.uploadFile; // Nuevo
    
    // 1. NUEVO: Extraemos la función updateActivity que acabamos de crear
    final updateActivity = activityNotifier.updateActivity; 

    return ActivityFormNotifier(
        submissionGradingCallback: submissionGrading,
        activityCallback: createActivity,
        
        // 2. NUEVO: Se la pasamos al constructor del formulario
        updateActivityCallback: updateActivity, 
        
        sendSubmissionCallback: sendActivity,
        sendSubmissionWithLinksCallback: sendActivityWithLinks,
        sendSubmissionWithFilesCallback: sendActivityWithFiles, // Nuevo
        sendSubmissionOfflineCallback: sendActivityOffline,
        uploadFileCallback: uploadFile, // Nuevo
    );
  },
);
