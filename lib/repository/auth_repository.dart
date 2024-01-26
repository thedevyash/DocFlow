import 'dart:convert';
import 'dart:js_interop';

import 'package:docs_clone/constants.dart';
import 'package:docs_clone/models/error_model.dart';
import 'package:docs_clone/models/user_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

//ye provider read only hai
final authRepositoryProvider = Provider(
  (ref) => AuthRepository(googleSignIn: GoogleSignIn(), client: Client()),
);

//provider riverpod ne dia hai
//values bhi edit kr skte hai
//type usermodel di hai
final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  //private to prevent other classes this
  final GoogleSignIn _googleSignIn;
  //alg se post put req ke bjye direct client bna dia
  final Client _client;
  AuthRepository({required GoogleSignIn googleSignIn, required Client client})
      : _googleSignIn = googleSignIn,
        _client = client;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error =
        ErrorModel(error: "Some unexpected error ocurred", data: null);
    try {
      //user ke paas email wgera hoga
      final user = await _googleSignIn.signIn();
      if (user != null) {
        //agar user login krlia hai to uska sara data model ke form mei bnakr userAcc mei daaldo
        final userAcc = UserModel(
            email: user.email,
            name: user.displayName!,
            profilePic: user.photoUrl!,
            token: 'user',
            uid: '');
//ab jb data aa gya hai to http post request bhejo api ko
//string ko uri mei convert krne ke liye Uri.porse() use krre
//req body kyuki post request hai.... umei userAcc ko json format mei convert krke bhejdo
//header isliye taki bta paye ki req body json format mei hi hai accept krlo bindaas
        var res = await _client.post(Uri.parse('$host/api/signup'),
            body: userAcc.toJson(),
            headers: {'Content-Type': 'application/json; charset=UTF-8'});
        switch (res.statusCode) {
          //user signup krne ke baad uski id mongoDb bnayga aur response mei bhejdega jisko tumko leke uss user ke model mei daalna hai
          case 200:
            //jsonDecode()...res string ke form mei hai to usko json bna dia taki alg se key aur value access kr paye
            //res se uid leke model mei daldi
            //res se token nikalkr model mei daaldia
            final newUser = userAcc.copyWith(
                uid: jsonDecode(res.body)['user']['_id'],
                token: jsonDecode(res.body)['token']);
            error = ErrorModel(error: null, data: newUser);
            break;
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }
}
