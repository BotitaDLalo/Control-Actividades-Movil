import 'package:aprende_mas/config/services/google/google_signin_api.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:aprende_mas/config/network/dio_client.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'openid', 'profile'],
);

class GoogleSigninApiImpl implements GoogleSigninApi {
  @override
  Future handlerGoogleLogout() => _googleSignIn.disconnect();

  @override
  Future<GoogleSignInAccount?> handlerGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      return googleUser;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<AuthUser> checkSignInStatus(String idToken) async {
    try {
      const uri = "/GoogleSignin/VerificarIdToken";
      final res = await dio.post(uri, data: {'IdToken': idToken});

      final user = AuthUserMapper.userJsonToEntity(res.data);
      return user;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> verifyExistingUser() async {
    try {
      final GoogleSignInAccount? currentUser = _googleSignIn.currentUser;

      if (currentUser == null) {
        return false;
      }
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }
  
  @override
  Future<bool> isSignedIn() async{
      bool isSignedIn = await _googleSignIn.isSignedIn();
      return isSignedIn;
  }
}
