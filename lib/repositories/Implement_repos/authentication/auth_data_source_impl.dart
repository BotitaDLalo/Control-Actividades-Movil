import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/config/network/dio_client.dart';
import 'package:aprende_mas/config/services/services.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Interface_repos/authentication/auth_data_source.dart';
import 'package:aprende_mas/config/utils/packages.dart';

class AuthDataSourceImpl implements AuthDataSource {
  final storageService = KeyValueStorageServiceImpl();
  @override
  Future<AuthUser> login(String email, String password) async {
    const uri = "/Login/InicioSesionUsuario";
    try {
      final res =
          await dio.post(uri, data: {'correo': email, 'clave': password});

      final user = AuthUserMapper.userJsonToEntity(res.data);
      return user;
    } on DioException catch (e) {
      debugPrint(e.message);
      if (e.response?.statusCode == 400 &&
          e.response?.data['errorCode'] == 1001) {
        final message = e.response?.data['errorMessage'];
        throw WrongCredentials(errorMessage: message);
      }
      if (e.type == DioExceptionType.connectionTimeout)
        throw ConnectionTimeout();
      throw UncontrolledError();
    } catch (e) {
      debugPrint(e.toString());
      throw UncontrolledError();
    }
  }

  @override
  Future<AuthUser> signin(
      {required String name,
      required String lastname,
      required String secondLastname,
      required String password,
      required String role,
      required String fcmToken}) async {
    try {
      const uri = "/Login/RegistroUsuario";

      final email = await storageService.getEmail();

      final res = await dio.post(uri, data: {
        'NombreUsuario': name,
        'ApellidoPaterno': lastname,
        'ApellidoMaterno': secondLastname,
        'Nombre': name,
        'Correo': email,
        'Clave': password,
        'TipoUsuario': role,
        'FcmToken': fcmToken
      });
      // final user = UserMapper.userSiginJsonToEntity(res.data);
      final user = AuthUserMapper.userJsonToEntity(res.data);

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data['errorCode'] == 1006) {
        final message = e.response?.data['errorMessage'];
        throw UserAlreadyExists(errorMessage: message);
      }
      if (e.type == DioExceptionType.connectionTimeout)
        throw ConnectionTimeout();
      throw UncontrolledError();
    } on UncontrolledError {
      throw UncontrolledError();
    }
  }

  @override
  Future<AuthUser> checkAuthStatus(String token) async {
    try {
      final res = await dio
          .get('/Login/VerificarToken', queryParameters: {"token": token});

      final user = AuthUserMapper.userJsonToEntity(res.data);

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UncontrolledError();
      }
      throw UncontrolledError();
    } catch (e) {
      throw UncontrolledError();
    }
  }

  @override
  Future<bool> resetPasswordRequest(String email) async {
    const uri = "/CorreoRestablecerPassword/EnvioCodigo";
    try {
      final resetPasswordStatus =
          await dio.post(uri, data: {"Destinatario": email});

      if (resetPasswordStatus.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout)
        throw ConnectionTimeout();
      throw UncontrolledError();
    } catch (e) {
      print(e);
      throw UncontrolledError();
    }
  }

  @override
  Future<AuthUser> loginGoogle() async {
    const uri = "/Login/IniciarSesionGoogle";
    final googleSigninApi = GoogleSigninApiImpl();
    try {
      final googleUserData = await googleSigninApi.handlerGoogleSignIn();
      final idToken = googleUserData?.idToken;

      final res = await dio.post(uri, data: {"IdToken": idToken});

      final user = AuthUserMapper.userJsonToEntity(res.data);
      return user;
    } on DioException catch (e) {
      final isSignedIn = await googleSigninApi.isSignedIn();
      if (isSignedIn) {
        await googleSigninApi.handlerGoogleLogout();
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConnectionTimeout();
      }
      throw UncontrolledError();
    } catch (e) {
      // throw CustomError(message: 'Ocurrio un error', errorCode: 1);
      debugPrint(e.toString());
      throw UncontrolledError();
    }
  }

  @override
  Future<AuthUser> registerMissingDataGoogle(
      {required String names,
      required String lastname,
      required String secondLastname,
      required String role,
      required String fcmToken}) async {
    try {
      const uri = "/Login/RegistrarDatosFaltantesGoogle";
      final idToken = await storageService.getToken();

      final res = await dio.post(uri, data: {
        "Nombres": names,
        "ApellidoPaterno": lastname,
        "ApellidoMaterno": secondLastname,
        "Role": role,
        "IdToken": idToken,
        "FcmToken": fcmToken
      });
      final user = AuthUserMapper.userJsonToEntity(res.data);
      return user;
    } catch (e) {
      debugPrint(e.toString());
      throw UncontrolledError();
    }
  }

  @override
  Future<bool> verifyExistingFcmToken(
      int id, String fcmToken, String role) async {
    try {
      const uri = "/Login/VerificarTokenFcm";
      // final id = await storageService.getId();
      // final role = await storageService.getRole();

      final res = await dio.post(uri,
          queryParameters: {"id": id, "fcmToken": fcmToken, "role": role});

      if (res.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      throw FcmTokenVerificatioFailed(
          message: "No se pudo verificar el token.");
    }
  }

  @override
  Future<AuthUser> registerAuthorizationCodeUser(
      String code, String? idToken) async {
    String uri = "";
    try {
      final email = await storageService.getEmail();

      Map<String, dynamic> body = {'Email': email, 'CodigoValidar': code};

      if (idToken!.isEmpty) {
        uri = "/Login/ValidarCodigoDocente";
      } else {
        uri = "/Login/ValidarCodigoDocenteGoogle";
        body['IdToken'] = idToken;
      }

      final res = await dio.post(uri, data: body);
      final user = AuthUserMapper.userJsonToEntity(res.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.data['errorCode'] == 1004) {
        throw InvalidAuthorizationCode();
      }
      if (e.response?.data['errorCode'] == 1005) {
        throw ExpiredAuthorizationCode();
      }

      if (e.type == DioExceptionType.connectionTimeout)
        throw ConnectionTimeout();
      throw UncontrolledError();
    } catch (e) {
      debugPrint(e.toString());
      throw UncontrolledError();
    }
  }

  @override
  Future<void> verifyEmailSignin(String email) async {
    debugPrint('🔍 verifyEmailSignin - Iniciando verificación para: $email');
    try {
      const uri = "/Login/VerificarEmailUsuario";

      final res = await dio.post(
        uri,
        data: '"$email"',
      );

      debugPrint('🔍 verifyEmailSignin - StatusCode recibido: ${res.statusCode}');
      debugPrint('🔍 verifyEmailSignin - Response data: ${res.data}');

      if (res.statusCode == 200) {
        debugPrint('✅ verifyEmailSignin - Email disponible para registro');
        return; // Solo retorna sin error
      }

      // Si no es 200, verificar si es error conocido
      final extensions = res.data['Extensions'];
      if (res.statusCode == 400 && extensions != null && extensions['errorCode'] == 1002) {
        final errorMessage = extensions['errorMessage'];
        final errorComment = extensions['errorComment'];
        debugPrint('❌ verifyEmailSignin - Email ya registrado: $errorMessage');
        throw InvalidEmailSignin(
            errorMessage: errorMessage, errorComment: errorComment);
      }

      debugPrint('⚠️ verifyEmailSignin - StatusCode inesperado: ${res.statusCode}');
      throw UncontrolledError(message: 'Respuesta inesperada del servidor');
    } on DioException catch (e) {
      debugPrint('🔍 verifyEmailSignin - DioException - StatusCode: ${e.response?.statusCode}');
      debugPrint('🔍 verifyEmailSignin - DioException - Response Data: ${e.response?.data}');
      if (e.response?.statusCode == 400) {
        final extensions = e.response?.data['Extensions'];
        final errorMessage = extensions?['errorMessage'];
        final errorComment = extensions?['errorComment'];
        debugPrint('✅ Lanzando InvalidEmailSignin desde DioException: $errorMessage');
        throw InvalidEmailSignin(
            errorMessage: errorMessage, errorComment: errorComment);
      }
      if (e.type == DioExceptionType.connectionTimeout)
        throw ConnectionTimeout();
      debugPrint('❌ verifyEmailSignin - Error no manejado: ${e.toString()}');
      throw UncontrolledError();
    } catch (e) {
      // No capturar InvalidEmailSignin, ConnectionTimeout - dejar que se propaguen
      if (e is InvalidEmailSignin || e is ConnectionTimeout) {
        debugPrint('🔄 Re-lanzando excepción específica: ${e.runtimeType}');
        rethrow;
      }
      debugPrint('❌ verifyEmailSignin - Exception general: ${e.toString()}');
      throw UncontrolledError();
    }
  }
}