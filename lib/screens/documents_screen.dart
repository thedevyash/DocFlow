import 'dart:async';

import 'package:docs_clone/colors.dart';
import 'package:docs_clone/common/widgets/loader.dart';
import 'package:docs_clone/models/document_model.dart';
import 'package:docs_clone/models/error_model.dart';
import 'package:docs_clone/repository/auth_repository.dart';
import 'package:docs_clone/repository/document_repository.dart';
import 'package:docs_clone/repository/socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill/quill_delta.dart' as delta;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:routemaster/routemaster.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: "Untitled Document");
  quill.QuillController? _controller;
  ScrollController _scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();
  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();
  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateTitle(
        token: ref.read(userProvider)!.token, id: widget.id, title: title);
  }

  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();

    socketRepository.changeListener((data) {
      _controller?.compose(
        Delta.fromJson(data['delta']),
        _controller?.selection ?? const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.remote,
      );
    });

    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': _controller!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  void fetchDocumentData() async {
    errorModel = await ref.read(documentRepositoryProvider).getDocumentById(
          ref.read(userProvider)!.token,
          widget.id,
        );

    if (errorModel!.data != null) {
      titleController.text = (errorModel!.data as DocumentModel).title;
      _controller = quill.QuillController(
        document: errorModel!.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                Delta.fromJson(errorModel!.data.content),
              ),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {});
    }

    _controller!.document.changes.listen((event) {
      if (event.source == quill.ChangeSource.remote) {
        Map<String, dynamic> map = {
          'delta': event.change,
          'room': widget.id,
        };
        socketRepository.typing(map);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Loader(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        foregroundColor: kBlueColor,
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                        text: 'http://localhost:3000/#/document/${widget.id}'))
                    .then(
                  (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Link copied!',
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.lock,
                color: Colors.white,
                size: 16,
              ),
              label: const Text("Share", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: kBlueColor),
            ),
          )
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Routemaster.of(context).replace('/'),
                child: Image.asset(
                  'assets/images/docs-logo.png',
                  height: 40,
                ),
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
                  onSubmitted: (value) => updateTitle(ref, value),
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
        child: Column(
          children: [
            quill.QuillToolbar(
                child: quill.QuillSimpleToolbar(
              configurations: quill.QuillSimpleToolbarConfigurations(
                  controller: _controller!),
            )),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Card(
                  color: kWhiteColor,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: quill.QuillEditor(
                        configurations: quill.QuillEditorConfigurations(
                            controller: _controller!),
                        focusNode: _focusNode,
                        scrollController: _scrollController),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
