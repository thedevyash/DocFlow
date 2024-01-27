import 'package:docs_clone/colors.dart';
import 'package:docs_clone/common/widgets/loader.dart';
import 'package:docs_clone/models/document_model.dart';
import 'package:docs_clone/models/error_model.dart';
import 'package:docs_clone/repository/auth_repository.dart';
import 'package:docs_clone/repository/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    //local storage mei pade token ko empty krdo
    ref.read(authRepositoryProvider).signOut();
    //maanlo user logged in to userprovider mei data hoga to user ko logged in se bhar le jane ke liye userprovidfer ko bhi null kro
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);

    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(
        SnackBar(
          content: Text(errorModel.error!),
        ),
      );
    }
  }

  void navigateToDocument(BuildContext context, String documentId) {
    Routemaster.of(context).push('/document/$documentId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(backgroundColor: kWhiteColor, elevation: 0, actions: [
          IconButton(
            icon: const Icon(Icons.add, color: kBlackColor),
            onPressed: () => createDocument(context, ref),
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: kRedColor,
            ),
            onPressed: () => signOut(ref),
          )
        ]),
        body: FutureBuilder<ErrorModel>(
          future: ref
              .watch(documentRepositoryProvider)
              .getDocuments(ref.watch(userProvider)!.token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            return Center(
              child: Container(
                width: 600,
                margin: EdgeInsets.only(top: 10),
                child: ListView.builder(
                  itemCount: snapshot.data!.data.length,
                  itemBuilder: (context, index) {
                    DocumentModel document = snapshot.data!.data[index];
                    return InkWell(
                      onTap: () => navigateToDocument(context, document.id),
                      child: SizedBox(
                        height: 60,
                        child: Card(
                          child: Center(
                            child: Text(document.title,
                                style: const TextStyle(fontSize: 17)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ));
  }
}
