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
import 'package:aprende_mas/config/data/db_local.dart';

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
  final CatalogNames cn;

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
      required this.sendSubmission,
      required this.cn
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
      // const caller = "loginUser";
      const authType = AuthenticatedType.auth;
      const caller = AuthCallers.loginUser;

      final user = await authRepository.login(email, password);

      if (user.estaAutorizado == AuthorizationUserStatus.pending.value) {
        await storageService.saveEmail(email);
        state = state.copyWith(isPendingAuthorizationUser: true);
      } else if (user.estaAutorizado == AuthorizationUserStatus.denied.value) {
        throw WrongCredentials(errorMessage: "Usuario denegado");
      } else if (user.estaAutorizado ==
          AuthorizationUserStatus.authorized.value) {
        int id = user.userId;
        String role = user.role;
        final isFcmTokenValid = await verifyExistingFcmToken(id, role);
        if (isFcmTokenValid) {
          _setLoggedUser(authType, caller, user);
        } else {
          throw FcmTokenVerificatioFailed();
        }
      } else {
        throw WrongCredentials(errorMessage: "Credenciales incorrectas");
      }
    } on WrongCredentials catch (e) {
      //badResponseDialog("Error de credenciales", e.errorMessage ?? "Correo o contraseña incorrectos");
      badResponseDialog("Correo o contraseña incorrectos",
          e.errorMessage ?? "Correo o contraseña incorrectos");
    } on FcmTokenVerificatioFailed catch (e) {
      badResponseDialog("Error de configuración",
          e.message ?? "Error con el token de notificaciones");
    } on ConnectionTimeout catch (e) {
      badResponseDialog(
          "Error de conexión", e.message ?? "Tiempo de espera agotado");
    } on UncontrolledError catch (e) {
      badResponseDialog(
          "Error en login", e.message ?? "Error inesperado al iniciar sesión");
    }
  }

  Future<bool> signinUser(
      {required String names,
      required String lastName,
      required String secondLastName,
      required String password,
      required String role}) async {
    try {
      // const caller = "siginUser";
      const authType = AuthenticatedType.auth;
      const caller = AuthCallers.signIn;

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
          _setLoggedUser(authType, caller, user);
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
      // const caller = "checkAuthStatus";
      const authType = AuthenticatedType.auth;
      const caller = AuthCallers.checkAuthStatus;

      final token = await storageService.getToken();
      if (token == "") return logout();
      final user = await authRepository.checkAuthStatus(token);

      int id = user.userId;
      String role = user.role;
      await verifyExistingFcmToken(id, role);

      _setLoggedUser(authType, caller, user);
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

  Future<void> verifyEmailSignin(String email) async {
    return authRepository.verifyEmailSignin(email);
  }

  Future<void> verifyConfirmationCode(String code) async {
    try {
      // const caller = "verifyConfirmationCode";
      final idToken = await storageService.getToken();

      final user =
          await authRepository.registerAuthorizationCodeUser(code, idToken);
      int id = user.userId;
      String role = user.role;
      if (user.estaAutorizado == AuthorizationUserStatus.authorized.value) {
        final isFcmTokenValid = await verifyExistingFcmToken(id, role);
        if (isFcmTokenValid) {
          AuthCallers caller;
          AuthenticatedType authType;

          if (idToken.isEmpty) {
            authType = AuthenticatedType.auth;
            caller = AuthCallers.verifyConfirmationCode;
            // _setLoggedUser(caller, user);
          } else {
            authType = AuthenticatedType.authGoogle;
            caller = AuthCallers.verifyConfirmationCodeGoogle;
            // _setLoggedGoogleUser(user);
          }

          _setLoggedUser(authType, caller, user);
        } else {
          throw FcmTokenVerificatioFailed();
        }
      }
    } on InvalidAuthorizationCode catch (e) {
      badResponseDialog("Código inválido",
          e.errorMessage ?? "El código de autorización no es válido");
    } on ExpiredAuthorizationCode catch (e) {
      badResponseDialog("Código expirado",
          e.errorMessage ?? "El código de autorización ha expirado");
    } on FcmTokenVerificatioFailed catch (e) {
      badResponseDialog("Error de configuración",
          e.message ?? "Error con el token de notificaciones");
    } on ConnectionTimeout catch (e) {
      badResponseDialog(
          "Error de conexión", e.message ?? "Tiempo de espera agotado");
    } on UncontrolledError catch (e) {
      badResponseDialog(
          "Error en verificación", e.message ?? "Error al verificar el código");
    }
  }

  void _setLoggedUser(
      AuthenticatedType authType, AuthCallers caller, AuthUser user) async {
    // const authType = AuthenticatedType.auth;
    const limit = 7;
    DateTime dateNow = DateTime.now();
    DateTime date7Days = dateNow.add(const Duration(days: limit));

    // final tokenFCM = await FirebaseCM.getFcmToken();

    await _saveUserDataKeyValue(
        user.token, user.userId, user.role, user.userName, authType);

    List<Group> lsGroups = await groups.getGroupsSubjects();

    List<Subject> lsSubjectsWithoutGroup =
        await subjects.getSubjectsWithoutGroup();

    ActiveUser activeUser = ActiveUser(
        userId: user.userId,
        userName: user.userName,
        email: user.email,
        activeDueDate: date7Days.toString(),
        role: user.role);

    if (caller == AuthCallers.checkAuthStatus &&
        authType == AuthenticatedType.auth) {
      authUserOffline.updateUser(date7Days.toString());

      if (user.role == cn.getRoleStudentName) {
        await _submissionsPending(lsGroups, lsSubjectsWithoutGroup);
      }
    }

    //& actualizamos los state del usuario (grupos, materias, actividades, entregables)
    await _saveUserAndUpdateState(
        activeUser, lsGroups, lsSubjectsWithoutGroup, caller, authType);

    // if (authType == AuthenticatedType.auth) {
    //   state = state.copyWith(
    //     authUser: user,
    //     authenticatedType: authType,
    //     authStatus: AuthStatus.authenticated,
    //     authConectionType: AuthConnectionType.online,
    //     errorMessage: '',
    //   );
    // } else if (authType == AuthenticatedType.authGoogle) {
    //   state = state.copyWith(
    //       authUser: user,
    //       authenticatedType: authType,
    //       authGoogleStatus: AuthGoogleStatus.authenticated,
    //       authConectionType: AuthConnectionType.offline,
    //       errorMessage: '');
    // }

    state = state.copyWith(
      authUser: user,
      authenticatedType: authType,
      authStatus:
          authType == AuthenticatedType.auth ? AuthStatus.authenticated : null,
      authGoogleStatus: authType == AuthenticatedType.authGoogle
          ? AuthGoogleStatus.authenticated
          : null,
      authConectionType: authType == AuthenticatedType.auth
          ? AuthConnectionType.online
          : AuthConnectionType.offline,
      errorMessage: '',
    );
  }

  Future<void> _saveUserAndUpdateState(
      ActiveUser user,
      List<Group> lsGroups,
      List<Subject> lsSubjectsWithoutGroup,
      AuthCallers caller,
      AuthenticatedType authType) async {


    if (authType == AuthenticatedType.auth && caller != AuthCallers.checkAuthStatus) {
      debugPrint('Intentando guardar usuario offline: ${user.userId}, ${user.userName}, ${user.email}, ${user.activeDueDate}, ${user.role}');
      try {
        await authUserOffline.insertUser(user.userId, user.userName, user.email,
            user.activeDueDate, user.role);
        debugPrint('Usuario offline guardado correctamente.');
        await DbLocal.printUsuariosActivos();
      } catch (e) {
        debugPrint('Error al guardar usuario offline: $e');
      }

      //& Guardar los grupos, materias y actividades offline (secuencial para evitar conflictos de BD)
      await groupsOffline.saveGroupSubjects(lsGroups);
      await subjectsOffline.saveSubjectsWithoutGroup(lsSubjectsWithoutGroup);
    }

    //& set para groups y subjects (no son async, ejecutar en paralelo lógico)
    setGroupsSubjectsState(lsGroups);
    setSubjectsWithoutGroupState(lsSubjectsWithoutGroup);

    await _getGroupsAndSubjects(
        caller, user.role, authType, lsGroups, lsSubjectsWithoutGroup);
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
      debugPrint('Resultado de getUser() offline: $dbUser');
      if (dbUser.isNotEmpty) {
        final userOffline = AuthOfflineUser.userOffilineJsonToEntity(dbUser);
        debugPrint('Usuario recuperado offline: ${userOffline.userId}, ${userOffline.userName}, ${userOffline.email}, ${userOffline.activeDueDate}, ${userOffline.role}');
        final userDateLimit = DateTime.parse(userOffline.activeDueDate);

        if (dateNow.isBefore(userDateLimit)) {
          debugPrint('Usuario offline vigente. Cargando grupos y materias...');
          List<Group> lsGroups = await groupsOffline.getGroupsSubjects();
          List<Subject> lsSubjectsWithoutGroup =
              await subjectsOffline.getSujectsWithoutGroup();
          _setLoggedOfflineUser(userOffline, lsGroups, lsSubjectsWithoutGroup);
        } else {
          debugPrint('Usuario offline expirado.');
          return;
        }
      } else {
        debugPrint('No hay usuario offline guardado.');
        return;
      }
    } catch (e) {
      debugPrint('Error en checkAuthStatusOffline: $e');
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

    //& Recolectar todas las materias
    List<Subject> allSubjects = [];

    for (var group in lsGroups) {
      for (var subj in group.materias ?? []) {
        allSubjects.add(subj as Subject);
      }
    }
    allSubjects.addAll(lsSubjectsWithoutGroup);

    //& Procesar materias en lotes para evitar saturar la app
    const int batchSize = 5; // Límite de materias por lote
    for (int i = 0; i < allSubjects.length; i += batchSize) {
      final batch = allSubjects.sublist(i, i + batchSize > allSubjects.length ? allSubjects.length : i + batchSize);
      List<Future<void>> batchFutures = [];

      for (var subject in batch) {
        final subjectId = subject.materiaId;

        batchFutures.add(
          Future(() async {
            try {
              await getAllActivitiesOfflineCallback(subjectId);
              List<Future<void>> submissionFutures = [];
              for (var act in subject.actividades ?? []) {
                final activity = act as Activity;
                final activityId = activity.activityId;
                submissionFutures.add(getSubmissionsOfflineCallback(activityId!));
              }
              //& Procesar submissions en lotes de 10 para limitar concurrencia
              const int submissionBatchSize = 10;
              for (int j = 0; j < submissionFutures.length; j += submissionBatchSize) {
                final subBatch = submissionFutures.sublist(j, j + submissionBatchSize > submissionFutures.length ? submissionFutures.length : j + submissionBatchSize);
                await Future.wait(subBatch);
              }
            } catch (error) {
              debugPrint(
                  "⚠️ [LOGIN] Error cargando actividades offline para materia $subjectId: $error");
            }
          }),
        );
      }

      //& Ejecutar el lote de materias en paralelo
      await Future.wait(batchFutures);
    }
  }

  //# LOGIN GOOGLE USER

  Future<void> loginGoogleUser() async {
    try {
      const authType = AuthenticatedType.authGoogle;
      const caller = AuthCallers.loginGoogleUser;

      final user = await authRepository.loginGoogle();

      if (user.estaAutorizado == AuthorizationUserStatus.authorized.value) {
        int id = user.userId;
        String role = user.role;

        final isFcmTokenValid = await verifyExistingFcmToken(id, role);
        if (!isFcmTokenValid) throw FcmTokenVerificatioFailed();

        // _setLoggedGoogleUser(user);
        _setLoggedUser(authType, caller, user);
      } else if (user.estaAutorizado == AuthorizationUserStatus.pending.value) {
        _saveUserDataLoginGoogle(user.email, user.token);
        if (user.requiereDatosAdicionales == true) {
          state = state.copyWith(theresMissingData: true);
        } else {
          state = state.copyWith(isPendingAuthorizationUser: true);
        }
      }
    } on FcmTokenVerificatioFailed catch (e) {
      badResponseDialog("Error de configuración",
          e.message ?? "Error con el token de notificaciones");
    } on ConnectionTimeout catch (e) {
      badResponseDialog(
          "Error de conexión", e.message ?? "Tiempo de espera agotado");
    } on UncontrolledError catch (e) {
      badResponseDialog(
          "Error en login", e.message ?? "Error al iniciar sesión con Google");
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
      const authType = AuthenticatedType.authGoogle;
      const caller = AuthCallers.missingDataGoogleUser;

      final fcmToken = await FirebaseCM.getFcmToken();
      if (fcmToken != null) {
        final user = await authRepository.registerMissingDataGoogle(
            names: names,
            lastname: lastname,
            secondLastname: secondLastname,
            role: role,
            fcmToken: fcmToken);

        if (user.estaAutorizado == AuthorizationUserStatus.authorized.value) {
          // _setLoggedGoogleUser(user);
          _setLoggedUser(authType, caller, user);
        } else if (user.estaAutorizado ==
            AuthorizationUserStatus.pending.value) {
          return true;
        }
        return false;
      }
      return false;
    } on UncontrolledError catch (e) {
      badResponseDialog("Error en registro",
          e.message ?? "Error al completar registro con Google");
      return false;
    }
  }

  void checkAuthGoogleStatus() async {
    try {
      // final currentUser = await googleSigninApi.verifyExistingUser();
      const authType = AuthenticatedType.authGoogle;
      const caller = AuthCallers.checkAuthGoogleStatus;

      final token = await storageService.getToken();
      if (token == "") return logoutGoogle();
      final user = await googleSigninApi.checkSignInStatus(token);
      int id = user.userId;
      String role = user.role;
      final isFcmTokenValid = await verifyExistingFcmToken(id, role);
      if (isFcmTokenValid) {
        // _setLoggedGoogleUser(user);
        _setLoggedUser(authType, caller, user);
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

  // void _setLoggedGoogleUser(AuthUser user) async {
  //   const authType = AuthenticatedType.authGoogle;

  //   await _saveUserDataKeyValue(
  //       user.token, user.userId, user.role, user.userName, authType);

  //   List<Group> lsGroups = await groups.getGroupsSubjects();

  //   List<Subject> lsSubjectsWithoutGroup =
  //       await subjects.getSubjectsWithoutGroup();

  //   _setUserDataGoogleState(
  //       lsGroups, lsSubjectsWithoutGroup, user.role, "", authType);

  //   state = state.copyWith(
  //       authUser: user,
  //       authenticatedType: authType,
  //       authGoogleStatus: AuthGoogleStatus.authenticated,
  //       authConectionType: AuthConnectionType.offline,
  //       errorMessage: '');
  // }

  // void _setUserDataGoogleState(
  //     List<Group> lsGroups,
  //     List<Subject> lsSubjectsWithoutGroup,
  //     String role,
  //     String caller,
  //     AuthenticatedType authType) async {

  //   //& set para groups y subjects y activities state
  //   setGroupsSubjectsState(lsGroups);
  //   setSubjectsWithoutGroupState(lsSubjectsWithoutGroup);

  //   _getGroupsAndSubjects(
  //       caller, role, authType, lsGroups, lsSubjectsWithoutGroup);
  // }

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
    } else {
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
    // Llamada al metodo para borrar la base de datos local
    //await DbLocal.deleteDatabaseLocal();
    await storageService.removeAuthType();
    await storageService.removeEmail();
    await storageService.removeId();
    await storageService.removeRole();
    await storageService.removeToken();
    await storageService.removeUserName();

  }

  Future<void> _getGroupsAndSubjects(
      AuthCallers caller,
      String role,
      AuthenticatedType authType,
      List<Group> lsGroups,
      List<Subject> lsSubjectsWithoutGroup) async {
    //& Recolectar todas las materias
    List<Subject> allSubjects = [];

    for (var group in lsGroups) {
      for (var subj in group.materias ?? []) {
        allSubjects.add(subj as Subject);
      }
    }
    allSubjects.addAll(lsSubjectsWithoutGroup);

    //& Procesar materias en lotes para evitar saturar la app
    const int batchSize = 5; // Límite de materias por lote
    for (int i = 0; i < allSubjects.length; i += batchSize) {
      final batch = allSubjects.sublist(i, i + batchSize > allSubjects.length ? allSubjects.length : i + batchSize);
      List<Future<void>> batchFutures = [];

      for (var subject in batch) {
        final subjectId = subject.materiaId;
        batchFutures.add(
          getAllActivitiesCallback(subjectId).then((_) async {
            //& Cargar entregables en lotes para limitar concurrencia
            List<Future<void>> submissionFutures = [];
            for (var act in subject.actividades ?? []) {
              final activity = act as Activity;
              final activityId = activity.activityId;

              submissionFutures.add(
                getSubmissionsCallback(activityId!).then((submissions) async {
                  if (caller != AuthCallers.checkAuthStatus &&
                      authType == AuthenticatedType.auth) {
                    try {
                      await activityOffline.saveSubmissions(
                          submissions, activityId);
                    } catch (e) {
                      debugPrint(
                          "⚠️ [LOGIN] Error guardando submissions para actividad $activityId: $e");
                    }
                  }
                }).catchError((error) {
                  debugPrint(
                      "⚠️ [LOGIN] Error cargando submissions para actividad $activityId: $error");
                  return null;
                }),
              );
            }
            //& Procesar submissions en lotes de 10 para limitar concurrencia
            const int submissionBatchSize = 10;
            for (int j = 0; j < submissionFutures.length; j += submissionBatchSize) {
              final subBatch = submissionFutures.sublist(j, j + submissionBatchSize > submissionFutures.length ? submissionFutures.length : j + submissionBatchSize);
              await Future.wait(subBatch);
            }
          }).catchError((error) {
            debugPrint(
                "🚨 [LOGIN] DioException en carga de actividades para materiaId=$subjectId: $error");
            // Continuar sin detener el login
            return null;
          }),
        );
      }

      //& Ejecutar el lote de materias en paralelo
      await Future.wait(batchFutures);
    }
  }
}
