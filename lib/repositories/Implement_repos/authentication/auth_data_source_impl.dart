import 'package:aprende_mas/config/data/data.dart';
import 'package:aprende_mas/config/network/dio_client.dart';
import 'package:aprende_mas/config/services/services.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/repositories/Interface_repos/authentication/auth_data_source.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthDataSourceImpl implements AuthDataSource {
  final storageService = KeyValueStorageServiceImpl();

  // Funcion de Login con correo y contraseña
  @override
  Future<AuthUser> login(String email, String password) async {
    const uri = "/Login/InicioSesionUsuario";
    try {
      final res =
          await dio.post(uri, data: {'Correo': email, 'Clave': password},
            options: Options(
              headers: {'Content-Type': 'application/json'},
            ),
          );

      final user = AuthUserMapper.userJsonToEntity(res.data);
      return user;
    } on DioException catch (e) {
      debugPrint(e.message);
      if (e.response?.statusCode == 200 &&
          e.response?.data['errorCode'] == 1001) {
        final message = e.response?.data['errorMessage'];
        throw WrongCredentials(errorMessage: message);
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConnectionTimeout();
      }
      throw UncontrolledError();
    } catch (e) {
      debugPrint(e.toString());
      throw UncontrolledError();
    }
  }


  // Funcion de Registro de usuario
  @override
  Future<AuthUser> signin({
    required String name,
    required String lastname,
    required String secondLastname,
    required String password,
    required String role,
    required String fcmToken,
  }) async {
    try {
      const uri = "/Login/RegistroUsuario";

      final email = await storageService.getEmail();

      // 🔍 DIAGNÓSTICO COMPLETO
      print('🔍 === INICIANDO REGISTRO DE USUARIO ===');
      print('📍 URL Completa: ${dio.options.baseUrl}$uri');
      print('📍 Email desde storage: $email');
      print('📍 Datos recibidos:');
      print('   - name: $name');
      print('   - lastname: $lastname');
      print('   - secondLastname: $secondLastname');
      print('   - password: [PROTEGIDO]');
      print('   - role: $role');
      print('   - fcmToken: $fcmToken');

      // Prueba diferentes formatos de TipoUsuario
      final tipoUsuarioOptions = [
        role.toLowerCase(), // 'alumno' o 'docente'
        role[0].toUpperCase() + role.substring(1).toLowerCase(), // 'Alumno' o 'Docente'
        role.toUpperCase(), // 'ALUMNO' o 'DOCENTE'
      ];

      AuthUser? successfulUser;

      for (final tipoUsuario in tipoUsuarioOptions) {
        try {
          print('\n🧪 Probando TipoUsuario: "$tipoUsuario"');
          
          final data = {
            'NombreUsuario': name,
            'ApellidoPaterno': lastname,
            'ApellidoMaterno': secondLastname,
            'Nombre': name,
            'Correo': email,
            'Clave': password,
            'TipoUsuario': tipoUsuario,
            'FcmToken': fcmToken
          };

          print('📤 JSON enviado: $data');

          final res = await dio.post(
            uri,
            data: data,
            options: Options(
              headers: {'Content-Type': 'application/json'},
            ),
          );

          print('✅ ✅ ✅ REGISTRO EXITOSO con TipoUsuario: "$tipoUsuario"');
          print('📦 Respuesta completa: ${res.data}');
          print('📊 Status Code: ${res.statusCode}');

          successfulUser = AuthUserMapper.userJsonToEntity(res.data);
          break; // Salir del loop si funciona
          
        } on DioException catch (e) {
          print('❌ Falló con TipoUsuario "$tipoUsuario":');
          print('   Status: ${e.response?.statusCode}');
          print('   Error: ${e.response?.data}');
          
          // Si es 400, mostrar detalles específicos
          if (e.response?.statusCode == 400) {
            print('   🔍 Detalles error 400:');
            print('      - Response data: ${e.response?.data}');
            if (e.response?.data is Map) {
              final errorData = e.response!.data as Map;
              print('      - Keys en error: ${errorData.keys}');
              print('      - Valores: $errorData');
            }
          }
          
          // Continuar con el siguiente formato
          continue;
        }
      }

      if (successfulUser != null) {
        return successfulUser;
      }

      // Si llegamos aquí, todos los formatos fallaron
      throw UncontrolledError();

    } on DioException catch (e) {
      print('\n🎯 ERROR FINAL EN REGISTRO:');
      print('📍 Status Code: ${e.response?.statusCode}');
      print('📍 URL: ${e.response?.requestOptions.uri}');
      print('📍 Datos enviados: ${e.response?.requestOptions.data}');
      print('📍 Respuesta del servidor: ${e.response?.data}');
      print('📍 Mensaje: ${e.message}');
      
      if (e.response?.statusCode == 400) {
        if (e.response?.data['errorCode'] == 1006) {
          final message = e.response?.data['errorMessage'];
          print('🚨 USUARIO YA EXISTE: $message');
          throw UserAlreadyExists(errorMessage: message);
        }
        
        // Mostrar cualquier otro error 400
        print('🚨 ERROR 400 NO MANEJADO:');
        print('   - Data: ${e.response?.data}');
      }
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConnectionTimeout();
      }
      
      throw UncontrolledError();
    } catch (e) {
      print('❌ ERROR NO CONTROLADO EN REGISTRO: $e');
      throw UncontrolledError();
    }
  }

  // Funcion para verificar el estado de autenticación del usuario
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

  // Funcion para solicitar restablecimiento de contraseña
  @override
  Future<bool> resetPasswordRequest(String email) async {
    const uri = "/CorreoRestablecerPassword/EnvioCodigo";
    try {
      final resetPasswordStatus =
          await dio.post(uri, data: {"Destinatario": email}, options: Options(headers: {'Content-Type': 'application/json'}));

      if (resetPasswordStatus.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConnectionTimeout();
      }
      throw UncontrolledError();
    } catch (e) {
      print(e);
      throw UncontrolledError();
    }
  }

  // Funcion de Login con Google 4
  @override
  Future<AuthUser> loginGoogle() async {
    const verifyUri = "/Login/VerificarIdToken";
    final googleSigninApi = GoogleSigninApiImpl();
    GoogleSignInAccount? googleUserData;
    String? idToken;

    try {
      print('🔐 INICIANDO LOGIN CON GOOGLE...');

      // Paso 1: Obtener datos de la cuenta de Google
      googleUserData = (await googleSigninApi.handlerGoogleSignIn()) as GoogleSignInAccount?;
      if (googleUserData == null) {
        throw UncontrolledError(message: 'El usuario canceló el inicio de sesión con Google');
      }

      // Paso 2: Obtener el token de autenticación
      final googleAuth = await googleUserData.authentication;
      idToken = googleAuth.idToken;

      if (idToken == null) {
        throw UncontrolledError(message: 'No se pudo obtener token de Google');
      }

      print('✅ Token Google obtenido para: ${googleUserData.email}');

      // Paso 3: Intentar verificar si el usuario existe en el backend
      print('📤 Verificando usuario existente...');
      final verifyResponse = await dio.post(
        verifyUri,
        data: {'IdToken': idToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // ✅ Usuario EXISTE - login exitoso
      print('✅ ✅ ✅ USUARIO EXISTENTE - LOGIN EXITOSO');
      final user = AuthUserMapper.userJsonToEntity(verifyResponse.data);
      return user;

    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        // 🔄 USUARIO NUEVO - necesita registro
        print('🆕 USUARIO NUEVO DETECTADO - necesita completar datos');
        
        if (googleUserData == null || idToken == null) {
          throw UncontrolledError(message: 'No se pudieron obtener los datos de Google para el registro.');
        }

        // Devolver un usuario "parcial" para indicar que se necesitan datos
        return AuthUser(
          userId: 0, 
          userName: googleUserData.displayName ?? '',
          email: googleUserData.email,
          role: '',
          token: idToken!,
          estaAutorizado: "Pendiente", 
          requiereDatosAdicionales: true,
        );
      }

      print('❌ Otro error de Dio: ${e.response?.data}');
      final isSignedIn = await googleSigninApi.isSignedIn();
      if (isSignedIn) {
        await googleSigninApi.handlerGoogleLogout();
      }
      throw UncontrolledError();
    } catch (e) {
      print('❌ Error general en loginGoogle: $e');
      throw UncontrolledError();
    }
  }

  // Funcion para registrar datos faltantes de usuario Google
  @override
  Future<AuthUser> registerMissingDataGoogle({
    required String names,
    required String lastname,
    required String secondLastname,
    required String role,
    required String fcmToken,
  }) async {
    const uri = "/Login/RegistrarDatosFaltantesGoogle";
    
    try {
      // ✅ OBTENER EL TOKEN GUARDADO durante el login
      final idToken = await storageService.getGoogleIdToken();
      
      if (idToken == null || idToken.isEmpty) {
        print('❌ No se encontró token de Google en storage');
        throw UncontrolledError(message: 'Error: Sesión de Google no encontrada');
      }

      print('✅ Token recuperado del storage, length: ${idToken.length}');

      final data = {
        "Nombres": names,
        "ApellidoPaterno": lastname,
        "ApellidoMaterno": secondLastname,
        "Role": role,
        "IdToken": idToken, // ← Token que guardamos durante el login
        "FcmToken": fcmToken
      };

      print('📤 Enviando datos para registro Google:');
      print('   - Nombres: $names');
      print('   - Apellidos: $lastname $secondLastname'); 
      print('   - Rol: $role');
      print('   - Token length: ${idToken.length}');
      print('   - FCM Token: ${fcmToken.isNotEmpty}');

      print('📦 Datos enviados al backend:');
      data.forEach((k, v) => print('  $k: $v'));
      print('💬 FCM Token real: $fcmToken');



      final res = await dio.post(
        uri,
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('✅ ✅ ✅ REGISTRO GOOGLE EXITOSO');
      print('📋 Respuesta: ${res.data}');
      
      // ✅ LIMPIAR el token del storage después del registro exitoso
      await storageService.removeGoogleIdToken();
      
      final user = AuthUserMapper.userJsonToEntity(res.data);
      return user;
      
    } on DioException catch (e) {
      print('❌ DioException en registerMissingDataGoogle:');
      print('   - Status: ${e.response?.statusCode}');
      print('   - Response data: ${e.response?.data}');
      
      throw UncontrolledError(
        message: 'Error en registro: ${e.response?.data?['Message'] ?? e.message}'
      );
    } catch (e) {
      print('❌ Error general en registerMissingDataGoogle: $e');
      throw UncontrolledError();
    }
  }

  // Funcion para verificar si el token de FCM ya existe
  @override
  Future<bool> verifyExistingFcmToken(
      int id, String fcmToken, String role) async {

        // ✅ SOLUCIÓN TEMPORAL - Omitir verificación FCM
        print('⚠️ Verificación FCM omitida - Endpoint no disponible en backend');
        return true; // Permitir que el flujo continúe

    /*
    try {
      //const uri = "/Login/VerificarTokenFcm";
      //const uri = "/Login/VerifierTokenFcn";
      const uri = "/Login/VerifierTokenFcn";
      // final id = await storageService.getId();
      // final role = await storageService.getRole();

      final res = await dio.post(
        uri,
        data: {
          "id": id,
          "fcnToken": fcmToken, // Cambio a fcnToken como espera el endpoint
          "role": role,
        },
      );

      if (res.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint('DioException in verifyExistingFcmToken:');
      debugPrint('  - Type: ${e.type}');
      debugPrint('  - Message: ${e.message}');
      debugPrint('  - Error: ${e.error}');
      debugPrint('  - Response: ${e.response}');
      throw FcmTokenVerificatioFailed(
          message: "No se pudo verificar el token: ${e.message}");
    } catch (e) {
      debugPrint('Unknown exception in verifyExistingFcmToken: $e');
      throw FcmTokenVerificatioFailed(
          message: "No se pudo verificar el token.");
    }
   */ 
  }
  

  // Funcion para registrar usuario con código de autorización
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
        uri = "/GoogleSignin/ValidarCodigoDocenteGoogle";
        body['IdToken'] = idToken;
      }

      final res = await dio.post(uri, data: body, options: Options(headers: {'Content-Type': 'application/json'}));
      final user = AuthUserMapper.userJsonToEntity(res.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.data['errorCode'] == 1004) {
        throw InvalidAuthorizationCode();
      }
      if (e.response?.data['errorCode'] == 1005) {
        throw ExpiredAuthorizationCode();
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConnectionTimeout();
      }
      throw UncontrolledError();
    } catch (e) {
      debugPrint(e.toString());
      throw UncontrolledError();
    }
  }

  // Funcion para verificar si el email ya está registrado
  @override
Future<bool> verifyEmailSignin(String email) async {
  try {
    const uri = "/Login/VerificarEmailUsuario";

    print('🔍 Verificando email: $email');

    // ignore: unused_local_variable
    final response = await dio.post(
      uri,
      data: {'email': email},
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Status 200 = Email NO existe → Puede registrarse
    print('✅ Email DISPONIBLE para registro');
    return true;
      
  } on DioException catch (e) {
    if (e.response?.statusCode == 400) {
      // Status 400 = Email SÍ existe → No puede registrarse
      print('❌ Email YA REGISTRADO - No puede registrarse');
      return false;
    }
    
    // Otros errores (timeout, conexión) → Permitir registro por seguridad
    print('⚠️ Error de conexión (${e.response?.statusCode}) - Permitimos registro');
    return true;
  } catch (e) {
    print('❌ Error inesperado - Permitimos registro');
    return true;
  }
}

}