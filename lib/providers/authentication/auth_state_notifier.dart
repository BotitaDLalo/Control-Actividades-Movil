import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/repositories/Implement_repos/activity/activity_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/authentication/auth_user_offline_repository_impl.dart';
import 'package:aprende_mas/config/services/google/google_signin_api.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/authentication/auth_state.dart';
import 'package:aprende_mas/repositories/Implement_repos/groups/groups_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/groups/groups_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/subjects/subjects_offline_repository_impl.dart';
import 'package:aprende_mas/repositories/Implement_repos/subjects/subjects_respository_impl.dart';
import 'package:aprende_mas/repositories/Interface_repos/authentication/auth_repository.dart';
import 'package:aprende_mas/config/data/key_value_storage_service.dart';
import 'package:aprende_mas/config/services/services.dart';
import 'package:aprende_mas/config/utils/utils.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService storageService;
  final GoogleSigninApi googleSigninApi;
  final AuthUserOfflineRepositoryImpl authUserOffline;
  final Function() getGroupsSubjectsCallback;
  final Function() getGroupsSubjectsOfflineCallback;
  final Function(int) getAllActivitiesCallback;
  // final Function(int) setAllActivitiesOfflineState;
  final Function(int) getSubmissionsCallback;
  final Function(int) getSubmissionsOfflineCallback;
  final Function(List<Group>) setGroupsSubjectsState;
  final Function(List<Subject>) setSubjectsWithoutGroupState;
  final GroupsRepositoryImpl groups;
  final SubjectsRespositoryImpl subjects;
  // final ActivityRepositoryImpl activity;
  final ActivityOfflineRepositoryImpl activityOffline;
  final GroupsOfflineRepositoryImpl groupsOffline;
  final SubjectsOfflineRepositoryImpl subjectsOffline;
  final Function(int) getAllActivitiesOfflineCallback;
  final Function(int, String) sendSubmission;

  AuthStateNotifier(
      {required this.authUserOffline,
      required this.authRepository,
      required this.storageService,
      required this.googleSigninApi,
      required this.setGroupsSubjectsState,
      required this.setSubjectsWithoutGroupState,
      required this.getSubmissionsCallback,
      required this.getSubmissionsOfflineCallback,
      required this.getAllActivitiesCallback,
      required this.getAllActivitiesOfflineCallback,
      required this.getGroupsSubjectsCallback,
      required this.getGroupsSubjectsOfflineCallback,
      required this.activityOffline,
      required this.groups,
      required this.subjects,
      required this.groupsOffline,
      required this.subjectsOffline,
      required this.sendSubmission
      // required this.activity,
      })
      : super(AuthState()) {
    checkInternet();
  }
  //# LOGIN USER

  void checkInternet() async {
    final checkInternet = await ConnectivityCheck.checkInternetConnectivity();
    if (checkInternet) {
      final authType = await storageService.getAuthType();
      final authTypeEnum = getAuthConnectionType(authType);
      if (authTypeEnum == AuthenticatedType.auth) {
        checkAuthStatus();
      } else if (authTypeEnum == AuthenticatedType.authGoogle) {
        checkAuthGoogleStatus();
      } else {
        logout();
      }
    } else {
      checkAuthStatusOffline();
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      const caller = "loginUser";
      final user = await authRepository.login(email, password);

      if (user.estaAutorizado == AuthorizationUserStatus.pending.value) {
        await storageService.saveEmail(email);
        state = state.copyWith(isPendingAuthorizationUser: true);
      } else if (user.estaAutorizado == AuthorizationUserStatus.denied.value) {
        //TODO: VISTA PARA NOTIFICAR QUE FUE DENEGADO
      } else if (user.estaAutorizado ==
          AuthorizationUserStatus.authorized.value) {
        int id = user.userId;
        String role = user.role;
        final isFcmTokenValid = await verifyExistingFcmToken(id, role);
        if (isFcmTokenValid) {
          _setLoggedUser(caller, user);
        } else {
          throw FcmTokenVerificatioFailed();
        }
      }
    } on WrongCredentials catch (e) {
      badResponseLogin(e.errorMessage);
    } on FcmTokenVerificatioFailed catch (e) {
      badResponseLogin(e.message);
    } on ConnectionTimeout catch (e) {
      connectionTimeoutLogin(e.message);
    } on UncontrolledError catch (e) {
      badResponseLogin(e.message);
    }
  }

  Future<bool> signinUser(
      {required String names,
      required String lastName,
      required String secondLastName,
      required String password,
      required String role}) async {
    try {
      const caller = "siginUser";
      final fcmToken = await FirebaseCM.getFcmToken();

      if (fcmToken != null) {
        final user = await authRepository.signin(
            name: names,
            lastname: lastName,
            secondLastname: secondLastName,
            password: password,
            role: role,
            fcmToken: fcmToken);

        if (user.estaAutorizado == AuthorizationUserStatus.authorized.value) {
          _setLoggedUser(caller, user);
        } else if (user.estaAutorizado ==
            AuthorizationUserStatus.pending.value) {
          return true;
        }
      }
      return false;
    } on FcmTokenVerificatioFailed catch (e) {
      badReponseSnackBar(e.message);
      rethrow;
    } on UserAlreadyExists catch (e) {
      badReponseSnackBar(e.errorMessage);
      rethrow;
    } on ConnectionTimeout catch (e) {
      badReponseSnackBar(e.message);
      rethrow;
      // logoutGoogle('Timeout');
    } on UncontrolledError catch (e) {
      badReponseSnackBar(e.message);
      rethrow;

      // logoutGoogle('Error no controlado');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      final resetPasswordStatus =
          await authRepository.resetPasswordRequest(email);
      if (!resetPasswordStatus) {
        return false;
      }
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  void checkAuthStatus() async {
    try {
      const caller = "checkAuthStatus";
      final token = await storageService.getToken();
      if (token == "") return logout();
      final user = await authRepository.checkAuthStatus(token);

      int id = user.userId;
      String role = user.role;
      await verifyExistingFcmToken(id, role);

      _setLoggedUser(caller, user);
    } on FcmTokenVerificatioFailed catch (e) {
      logout(e.message);
    } catch (e) {
      logout();
    }
  }

  void badResponseLogin([String? errorMessage]) {
    state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        // user: null,
        errorMessage: errorMessage,
        errorHandlingStyle: ErrorHandlingStyle.snackBar);
  }

  void badResponseGoogleLogin([String? errorMessage]) {
    state = state.copyWith(
        authGoogleStatus: AuthGoogleStatus.notAuthenticated,
        // user: null,
        errorMessage: errorMessage,
        errorHandlingStyle: ErrorHandlingStyle.snackBar);
  }

  void badReponseSnackBar([String? errorMessage]) {
    state = state.copyWith(
        errorMessage: errorMessage,
        errorHandlingStyle: ErrorHandlingStyle.snackBar);
  }

  void badResponseDialog([String? errorMessage, String? errorComment]) {
    state = state.copyWith(
        errorMessage: errorMessage,
        errorComment: errorComment,
        errorHandlingStyle: ErrorHandlingStyle.dialog);
  }

  Future<bool> verifyExistingFcmToken(int id, String role) async {
    final fcmToken = await FirebaseCM.getFcmToken();
    if (fcmToken != null) {
      bool tokenIsRegistered =
          await authRepository.verifyExistingFcmToken(id, fcmToken, role);
      return tokenIsRegistered;
    }
    return false;
  }

  Future<bool> verifyEmailSignin(String email) async {
    try {
      bool res = await authRepository.verifyEmailSignin(email);
      return res;
    } on InvalidEmailSignin catch (e) {
      badResponseDialog(e.errorMessage, e.errorComment);
    } on ConnectionTimeout catch (e) {
      badReponseSnackBar(e.message);
    } on UncontrolledError catch (e) {
      badReponseSnackBar(e.message);
    }
    return false;
  }

  Future<void> verifyConfirmationCode(String code) async {
    try {
      const caller = "verifyConfirmationCode";
      final idToken = await storageService.getToken();

      final user =
          await authRepository.registerAuthorizationCodeUser(code, idToken);
      int id = user.userId;
      String role = user.role;
      if (user.estaAutorizado == AuthorizationUserStatus.authorized.value) {
        final isFcmTokenValid = await verifyExistingFcmToken(id, role);
        if (isFcmTokenValid) {
          if (idToken.isEmpty) {
            _setLoggedUser(caller, user);
          } else {
            _setLoggedGoogleUser(user);
          }
        } else {
          throw FcmTokenVerificatioFailed();
        }
      }
    } on InvalidAuthorizationCode catch (e) {
      badReponseSnackBar(e.errorMessage);
    } on ExpiredAuthorizationCode catch (e) {
      badReponseSnackBar(e.errorMessage);
    } on FcmTokenVerificatioFailed catch (e) {
      badReponseSnackBar(e.message);
    } on ConnectionTimeout catch (e) {
      badReponseSnackBar(e.message);
    } on UncontrolledError catch (e) {
      badReponseSnackBar(e.message);
    }
  }

  void _setLoggedUser(String caller, AuthUser user) async {
    const limit = 7;
    const authType = AuthenticatedType.auth;
    DateTime dateNow = DateTime.now();
    DateTime date7Days = dateNow.add(const Duration(days: limit));

    // final tokenFCM = await FirebaseCM.getFcmToken();

    await _saveUserDataKeyValue(
        user.token, user.userId, user.role, user.userName, authType);

    if (caller == "loginUser" ||
        caller == "siginUser" ||
        caller == "verifyConfirmationCode") {
      ActiveUser activeUser = ActiveUser(
          userId: user.userId,
          userName: user.userName,
          email: user.email,
          activeDueDate: date7Days.toString(),
          role: user.role);

      List<Group> lsGroups = await groups.getGroupsSubjects();
      List<Subject> lsSubjectsWithoutGroup =
          await subjects.getSubjectsWithoutGroup();

      //& actualizamos los state del usuario (grupos, materias, actividades, entregables)
      _saveUserAndUpdateState(activeUser, lsGroups, lsSubjectsWithoutGroup);

      //& TOKEN FIREBASE
    } else if (caller == "checkAuthStatus") {
      authUserOffline.updateUser(date7Days.toString());
      List<Group> lsGroups = await groups.getGroupsSubjects();
      List<Subject> lsSubjectsWithoutGroup =
          await subjects.getSubjectsWithoutGroup();

      await _submissionsPending(lsGroups, lsSubjectsWithoutGroup);

      await _updateUserState(lsGroups, lsSubjectsWithoutGroup);
    }

    state = state.copyWith(
      authUser: user,
      authenticatedType: authType,
      authStatus: AuthStatus.authenticated,
      authConectionType: AuthConnectionType.online,
      errorMessage: '',
    );
  }

  void _saveUserAndUpdateState(ActiveUser user, List<Group> lsGroups,
      List<Subject> lsSubjectsWithoutGroup) async {
    //& Guardar el usuario offline
    await authUserOffline.insertUser(
        user.userId, user.userName, user.email, user.activeDueDate, user.role);

    //& Guardar los grupos, materias y actividades offline (paralelizado)
    await Future.wait([
      groupsOffline.saveGroupSubjects(lsGroups),
      subjectsOffline.saveSubjectsWithoutGroup(lsSubjectsWithoutGroup),
    ]);

    //& set para groups y subjects (no son async, ejecutar en paralelo lógico)
    setGroupsSubjectsState(lsGroups);
    setSubjectsWithoutGroupState(lsSubjectsWithoutGroup);

    //& Recolectar todas las actividades y entregables para cargar en paralelo
    List<Future<void>> allFutures = [];

    //& set para activity state grupos y materias (paralelizado)
    for (var group in lsGroups) {
      for (var subj in group.materias ?? []) {
        final subject = subj as Subject;
        final subjectId = subject.materiaId;

        //& Cargar actividades en paralelo
        allFutures.add(
          getAllActivitiesCallback(subjectId).then((_) async {
            //& Cargar entregables en paralelo para cada actividad
            List<Future<void>> submissionFutures = [];
            for (var act in subj.actividades ?? []) {
              final activity = act as Activity;
              final activityId = activity.activityId;

              submissionFutures.add(
                getSubmissionsCallback(activityId!).then((submissions) async {
                  await activityOffline.saveSubmissions(submissions, activityId);
                }),
              );
            }
            await Future.wait(submissionFutures);
          }),
        );
      }
    }

    //& set para activity state materias sin grupo (paralelizado)
    for (var subject in lsSubjectsWithoutGroup) {
      final subjectId = subject.materiaId;

      allFutures.add(
        getAllActivitiesCallback(subjectId).then((_) async {
          List<Future<void>> submissionFutures = [];
          for (var act in subject.actividades ?? []) {
            final activity = act as Activity;
            final activityId = activity.activityId;

            submissionFutures.add(
              getSubmissionsCallback(activityId!).then((submissions) async {
                await activityOffline.saveSubmissions(submissions, activityId);
              }),
            );
          }
          await Future.wait(submissionFutures);
        }),
      );
    }

    //& Ejecutar todas las operaciones en paralelo
    await Future.wait(allFutures);
  }

  Future<void> _updateUserState(
      List<Group> lsGroups, List<Subject> lsSubjectsWithoutGroup) async {
    //& set para groups y subject
    setGroupsSubjectsState(lsGroups);
    setSubjectsWithoutGroupState(lsSubjectsWithoutGroup);

    //& Recolectar todas las operaciones para ejecutar en paralelo
    List<Future<void>> allFutures = [];

    for (var group in lsGroups) {
      for (var sub in group.materias ?? []) {
        final subject = sub as Subject;
        final subjectId = subject.materiaId;
        
        allFutures.add(
          getAllActivitiesCallback(subjectId).then((_) async {
            List<Future<void>> submissionFutures = [];
            for (var act in sub.actividades ?? []) {
              final activity = act as Activity;
              final activityId = activity.activityId;
              submissionFutures.add(getSubmissionsCallback(activityId!));
            }
            await Future.wait(submissionFutures);
          }),
        );
      }
    }

    for (var subject in lsSubjectsWithoutGroup) {
      final subjectId = subject.materiaId;
      
      allFutures.add(
        getAllActivitiesCallback(subjectId).then((_) async {
          List<Future<void>> submissionFutures = [];
          for (var act in subject.actividades ?? []) {
            final activity = act as Activity;
            final activityId = activity.activityId;
            submissionFutures.add(getSubmissionsCallback(activityId!));
          }
          await Future.wait(submissionFutures);
        }),
      );
    }

    await Future.wait(allFutures);
  }

  Future<void> _submissionsPending(
      List<Group> lsGroups, List<Subject> lsSubjectsWithoutGroup) async {
    List<Submission> lsSubmissionsPending = [];

    //& set para activity state
    if (lsGroups.isNotEmpty) {
      for (var group in lsGroups) {
        for (var subj in group.materias ?? []) {
          for (var act in subj.actividades ?? []) {
            final activity = act as Activity;
            final activityId = activity.activityId;

            //& Guardar entregables para submissions state
            List<Submission> lsSubmissions =
                await activityOffline.getSubmissionsPending(activityId!);
            lsSubmissionsPending.addAll(lsSubmissions);
          }
        }
      }
    }

    if (lsSubjectsWithoutGroup.isNotEmpty) {
      for (var subject in lsSubjectsWithoutGroup) {
        for (var act in subject.actividades ?? []) {
          final activity = act as Activity;
          final activityId = activity.activityId;

          //& Guardar entregables para submissions state
          List<Submission> lsSubmissions =
              await activityOffline.getSubmissionsPending(activityId!);
          lsSubmissionsPending.addAll(lsSubmissions);
        }
      }
    }

    if (lsSubmissionsPending.isNotEmpty) {
      for (var submission in lsSubmissionsPending) {
        int activityId = submission.activityId ?? -1;
        if (activityId != -1) {
          String answer = submission.answer ?? "";
          bool submissionSentSuccess = await sendSubmission(activityId, answer);

          if (submissionSentSuccess) {
            int submissionId = submission.submissionId;
            await activityOffline.deleteSubmissionOfflineSent(submissionId);
          }
        }
      }
    }
  }

  void logout([String? errorMessage]) {
    _deleteUserData();
    state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        // user: null,
        errorMessage: errorMessage);
  }

  //# LOGIN USER OFFLINE

  void checkAuthStatusOffline() async {
    try {
      DateTime dateNow = DateTime.now();
      final dbUser = await authUserOffline.getUser();
      if (dbUser.isNotEmpty) {
        final userOffline = AuthOfflineUser.userOffilineJsonToEntity(dbUser);
        final userDateLimit = DateTime.parse(userOffline.activeDueDate);

        if (dateNow.isBefore(userDateLimit)) {
          List<Group> lsGroups = await groupsOffline.getGroupsSubjects();
          List<Subject> lsSubjectsWithoutGroup =
              await subjectsOffline.getSujectsWithoutGroup();
          //TODO: MANDAR A TRAER Materias sin grupo
          _setLoggedOfflineUser(userOffline, lsGroups, lsSubjectsWithoutGroup);
        } else {
          return;
        }
      } else {
        return;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  void _setLoggedOfflineUser(AuthOfflineUser userOffline, List<Group> lsGroups,
      List<Subject> lsSubjectsWithoutGroup) async {
    debugPrint("EL USUARIO NO TIENE INTERNET");

    final user = AuthUser(
        userId: userOffline.userId,
        userName: userOffline.userName,
        email: userOffline.email,
        role: userOffline.role,
        token: "");
    // _updateUserState(lsGroups, lsSubjectsWithoutGroup);
    _updateUserStateOffline(lsGroups, lsSubjectsWithoutGroup);

    state = state.copyWith(
      authUser: user,
      authStatus: AuthStatus.authenticated,
      authenticatedType: AuthenticatedType.auth,
      authConectionType: AuthConnectionType.offline,
      errorMessage: '',
    );
  }

  Future<void> _updateUserStateOffline(
      List<Group> lsGroups, List<Subject> lsSubjectsWithoutGroup) async {
    //& set para groups y subject
    setGroupsSubjectsState(lsGroups);
    setSubjectsWithoutGroupState(lsSubjectsWithoutGroup);

    //& Recolectar todas las operaciones para ejecutar en paralelo
    List<Future<void>> allFutures = [];

    for (var group in lsGroups) {
      for (var sub in group.materias ?? []) {
        final subject = sub as Subject;
        final subjectId = subject.materiaId;
        
        allFutures.add(
          getAllActivitiesOfflineCallback(subjectId).then((_) async {
            List<Future<void>> submissionFutures = [];
            for (var act in sub.actividades ?? []) {
              final activity = act as Activity;
              final activityId = activity.activityId;
              submissionFutures.add(getSubmissionsOfflineCallback(activityId!));
            }
            await Future.wait(submissionFutures);
          }),
        );
      }
    }

    for (var subject in lsSubjectsWithoutGroup) {
      final subjectId = subject.materiaId;
      
      allFutures.add(
        getAllActivitiesOfflineCallback(subjectId).then((_) async {
          List<Future<void>> submissionFutures = [];
          for (var act in subject.actividades ?? []) {
            final activity = act as Activity;
            final activityId = activity.activityId;
            submissionFutures.add(getSubmissionsOfflineCallback(activityId!));
          }
          await Future.wait(submissionFutures);
        }),
      );
    }

    await Future.wait(allFutures);
  }

  //# LOGIN GOOGLE USER

  Future<void> loginGoogleUser() async {
    try {
      final user = await authRepository.loginGoogle();

      if (user.estaAutorizado == AuthorizationUserStatus.authorized.value) {
        int id = user.userId;
        String role = user.role;

        final isFcmTokenValid = await verifyExistingFcmToken(id, role);
        if (!isFcmTokenValid) throw FcmTokenVerificatioFailed();

        _setLoggedGoogleUser(user);
      } else if (user.estaAutorizado == AuthorizationUserStatus.pending.value) {
        _saveUserDataLoginGoogle(user.email, user.token);
        if (user.requiereDatosAdicionales == true) {
          state = state.copyWith(theresMissingData: true);
        } else {
          state = state.copyWith(isPendingAuthorizationUser: true);
        }
      }
    } on FcmTokenVerificatioFailed catch (e) {
      badResponseLogin(e.message);
    } on ConnectionTimeout catch (e) {
      connectionTimeoutLoginGoogle(e.message);
    } on UncontrolledError catch (e) {
      badResponseLogin(e.message);
    }
  }

  void connectionTimeoutLogin(String message) async {
    logout();
    badResponseLogin(message);
  }

  void connectionTimeoutLoginGoogle(String message) async {
    logoutGoogle();
    badResponseLogin(message);
  }

  void _saveUserDataLoginGoogle(String email, String token) async {
    await storageService.saveEmail(email);
    await storageService.saveToken(token);
  }

  Future<bool> missingDataGoogleUser(
      String names, String lastname, String secondLastname, String role) async {
    try {
      final fcmToken = await FirebaseCM.getFcmToken();
      if (fcmToken != null) {
        final user = await authRepository.registerMissingDataGoogle(
            names: names,
            lastname: lastname,
            secondLastname: secondLastname,
            role: role,
            fcmToken: fcmToken);

        if (user.estaAutorizado == AuthorizationUserStatus.authorized.value) {
          _setLoggedGoogleUser(user);
        } else if (user.estaAutorizado ==
            AuthorizationUserStatus.pending.value) {
          return true;
        }
        return false;
      }
      return false;
    } on UncontrolledError catch (e) {
      badReponseSnackBar(e.message);
      return false;
    }
  }

  void checkAuthGoogleStatus() async {
    try {
      // final currentUser = await googleSigninApi.verifyExistingUser();
      final token = await storageService.getToken();
      if (token == "") return logoutGoogle();
      final user = await googleSigninApi.checkSignInStatus(token);
      int id = user.userId;
      String role = user.role;
      final isFcmTokenValid = await verifyExistingFcmToken(id, role);
      if (isFcmTokenValid) {
        _setLoggedGoogleUser(user);
      } else {
        throw FcmTokenVerificatioFailed();
      }
    } on FcmTokenVerificatioFailed {
      // badResponseLogin(e.message);
      logoutGoogle();
    } catch (e) {
      logoutGoogle();
    }
  }

  void _setLoggedGoogleUser(AuthUser user) async {
    const authType = AuthenticatedType.authGoogle;
    await _saveUserDataKeyValue(
        user.token, user.userId, user.role, user.userName, authType);

    List<Group> lsGroups = await groups.getGroupsSubjects();
    List<Subject> lsSubjectsWithoutGroup =
        await subjects.getSubjectsWithoutGroup();

    _setUserDataGoogleState(lsGroups, lsSubjectsWithoutGroup);

    state = state.copyWith(
        authUser: user,
        authenticatedType: authType,
        authGoogleStatus: AuthGoogleStatus.authenticated,
        authConectionType: AuthConnectionType.offline,
        errorMessage: '');
  }

  void _setUserDataGoogleState(
      List<Group> lsGroups, List<Subject> lsSubjectsWithoutGroup) async {
    //& set para groups y subjects y activities state
    setGroupsSubjectsState(lsGroups);
    setSubjectsWithoutGroupState(lsSubjectsWithoutGroup);

    //& Recolectar todas las actividades y entregables para cargar en paralelo
    List<Future<void>> allFutures = [];

    //& set para activity state (paralelizado)
    for (var group in lsGroups) {
      for (var subj in group.materias ?? []) {
        final subject = subj as Subject;
        final subjectId = subject.materiaId;

        //& Actualizamos el state de actividades en paralelo
        allFutures.add(
          getAllActivitiesCallback(subjectId).then((_) async {
            List<Future<void>> submissionFutures = [];
            for (var act in subj.actividades ?? []) {
              final activity = act as Activity;
              final activityId = activity.activityId;

              submissionFutures.add(
                getSubmissionsCallback(activityId!),
              );
            }
            await Future.wait(submissionFutures);
          }),
        );
      }
    }

    //& set para activity state materias sin grupo (paralelizado)
    for (var subject in lsSubjectsWithoutGroup) {
      final subjectId = subject.materiaId;

      allFutures.add(
        getAllActivitiesCallback(subjectId).then((_) async {
          List<Future<void>> submissionFutures = [];
          for (var act in subject.actividades ?? []) {
            final activity = act as Activity;
            final activityId = activity.activityId;

            submissionFutures.add(
              getSubmissionsCallback(activityId!),
            );
          }
          await Future.wait(submissionFutures);
        }),
      );
    }

    //& Ejecutar todas las operaciones en paralelo
    await Future.wait(allFutures);
  }

  Future<void> logoutGoogle([String? errorMessage]) async {
    try {
      await googleSigninApi.handlerGoogleLogout();
      _deleteUserData();
    } catch (e) {
      debugPrint(e.toString());
      // return;
    } finally {
      state = state.copyWith(
          authGoogleStatus: AuthGoogleStatus.notAuthenticated,
          // user: null,
          errorMessage: errorMessage);
    }
  }

  popAuth() async {
    bool isSignedIn = await googleSigninApi.isSignedIn();
    if (isSignedIn) {
      await googleSigninApi.handlerGoogleLogout();
    }else{
      storageService.removeEmail();
    }
    state = AuthState();
  }

//# KEY VALUE STORAGE
  _saveUserDataKeyValue<T>(T valueToken, T valueId, T valueRole,
      T valueUserName, T valueAuthType) async {
    await storageService.saveToken(valueToken);
    await storageService.saveId(valueId);
    await storageService.saveRole(valueRole);
    await storageService.saveUserName(valueUserName);
    await storageService.saveAuthType(valueAuthType);
  }

  void _deleteUserData() async {
    await authUserOffline.deleteUser();
    await storageService.removeAuthType();
    await storageService.removeEmail();
    await storageService.removeId();
    await storageService.removeRole();
    await storageService.removeToken();
    await storageService.removeUserName();
  }
}
