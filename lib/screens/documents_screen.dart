import 'package:docs_clone/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: "Untitled Document");
  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: kBlueColor,
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.lock,
                color: Colors.white,
                size: 16,
              ),
              label: Text("Share"),
              style: ElevatedButton.styleFrom(backgroundColor: kBlueColor),
            ),
          )
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Image.asset(
                'assets/images/docs-logo.png',
                height: 40,
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kBlueColor)),
                      contentPadding: EdgeInsets.only(left: 10)),
                ),
              )
            ],
          ),
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 0.1, color: kGreyColor)),
            )),
      ),
      body: Center(
        child: Text(widget.id),
      ),
    );
  }
}
