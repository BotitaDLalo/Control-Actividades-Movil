import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Implement_repos/authentication/auth_data_source_impl.dart';
import 'package:aprende_mas/repositories/Interface_repos/authentication/auth_data_source.dart';
import 'package:aprende_mas/repositories/Interface_repos/authentication/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({AuthDataSource? dataSource})
      : dataSource = dataSource ?? AuthDataSourceImpl();

  @override
  Future<AuthUser> login(String email, String password) {
    return dataSource.login(email, password);
  }

  @override
  Future<AuthUser> signin(
      {required String name,
      required String lastname,
      required String secondLastname,
      required String password,
      required String role,
      required String fcmToken}) {
    return dataSource.signin(
        name: name,
        lastname: lastname,
        secondLastname: secondLastname,
        password: password,
        role: role,
        fcmToken: fcmToken);
  }

  @override
  Future<AuthUser> checkAuthStatus(String token) {
    return dataSource.checkAuthStatus(token);
  }

  @override
  Future<bool> resetPasswordRequest(String email) {
    return dataSource.resetPasswordRequest(email);
  }

  @override
  Future<AuthUser> loginGoogle() {
    return dataSource.loginGoogle();
  }

  @override
  Future<AuthUser> registerMissingDataGoogle(
      {required String names,
      required String lastname,
      required String secondLastname,
      required String role,
      required String fcmToken}) {
    return dataSource.registerMissingDataGoogle(
        names: names,
        lastname: lastname,
        secondLastname: secondLastname,
        role: role,
        fcmToken: fcmToken);
  }

  @override
  Future<bool> verifyExistingFcmToken(int id, String fcmToken, String role) {
    return dataSource.verifyExistingFcmToken(id, fcmToken, role);
  }

  @override
  Future<AuthUser> registerAuthorizationCodeUser(String code, String? idToken) {
    return dataSource.registerAuthorizationCodeUser(code, idToken);
  }

  @override
  Future<void> verifyEmailSignin(String email) {
    return dataSource.verifyEmailSignin(email);
  }
}
