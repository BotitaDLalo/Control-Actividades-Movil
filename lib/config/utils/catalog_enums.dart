enum AuthStatus { checking, authenticated, notAuthenticated }

enum AuthenticatedType { auth, authGoogle, undefined }

enum AuthGoogleStatus { checking, authenticated, notAuthenticated }

enum RegisterStatus { registered, notRegistered }

enum AuthConnectionType { online, offline, unverified }

enum ErrorHandlingStyle { snackBar, dialog, undefined }

enum AuthCallers {
  loginUser,
  signIn,
  checkAuthStatus,
  verifyConfirmationCode,
  verifyConfirmationCodeGoogle,
  loginGoogleUser,
  missingDataGoogleUser,
  checkAuthGoogleStatus
}

enum AuthorizationUserStatus {
  authorized("Autorizado"),
  denied("Denegado"),
  pending("Pendiente");

  final String value;
  const AuthorizationUserStatus(this.value);
}

AuthenticatedType getAuthConnectionType(String authType) {
  final authTypeEnum = AuthenticatedType.values.firstWhere(
    (element) => element.toString() == authType,
    orElse: () => AuthenticatedType.undefined,
  );

  return authTypeEnum;
}
