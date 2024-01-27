import 'package:docs_clone/models/error_model.dart';
import 'package:docs_clone/repository/auth_repository.dart';
import 'package:docs_clone/router.dart';
import 'package:docs_clone/screens/home_screen.dart';
import 'package:docs_clone/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

//router ke liye navigator use nhi krre kyuki dynamic links nhi use kr pate islliye routemaster use krre kyui ye ek wrapper h navigtor 2.0 ke upr
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.
  ErrorModel? errorModel;

  @override
  void initState() {
    getUser();
    super.initState();
  }

//b check krre hi ki user dat hai ki nhi agar hai to homescreen wrna loginscreen
//errormodel ke paas agr data hua to user logged in wrna nhi

  void getUser() async {
    errorModel = await ref.read(authRepositoryProvider).getUserData();
    print(errorModel!.data);
    if (errorModel != null && errorModel!.data != null) {
      print("error null nhi hai");
      ref.read(userProvider.notifier).update((state) => errorModel!.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      //agar user null hi to loginScreen wrna homeScreen
      routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
        //ek user bnmaya jo check krega ki userprovider pr data h ki nhi watch() ka use krke
        final user = ref.watch(userProvider);
        if (user != null && user.token.isNotEmpty) {
//route for logged in
          return loggedInRoute;
        }
        return loggedOutRoute;
      }),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
