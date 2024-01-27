import 'package:shared_preferences/shared_preferences.dart';

//jwt token ko loca;lly store krre hai through shared preferences
class LocalStorageRepository {
  void setToken(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('x-auth-token', token);
  }

//ab getter bna dia hai
//x-auth-token loclly stored token ki key hi jiske through hum token ko access krenge
  Future<String?> getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    //this cn be nullable ...gar user first time login krra hai...ya fir koi error ho gyi hai
    String? token = preferences.getString('x-auth-token');
    return token;
  }
}
