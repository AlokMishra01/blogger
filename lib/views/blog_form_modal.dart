import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BlogFormModal extends StatefulWidget {
  const BlogFormModal({Key? key}) : super(key: key);

  @override
  State<BlogFormModal> createState() => _BlogFormModalState();
}

class _BlogFormModalState extends State<BlogFormModal> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  String? _image;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _description,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          if (_image == null)
            MaterialButton(
              color: Colors.red,
              child: Text('Pick Image'),
              onPressed: () async {
                final ImagePicker _picker = ImagePicker();
                final image = await _picker.pickImage(
                  source: ImageSource.camera,
                );

                if (image == null) {
                  return;
                }

                final FirebaseStorage storage = FirebaseStorage.instance;

                try {
                  final result = await storage
                      .ref(
                        'blogs/${DateTime.now().microsecondsSinceEpoch}',
                      )
                      .putFile(File(image.path));
                  log(result.ref.fullPath);
                  _image = await result.ref.getDownloadURL();
                  setState(() {});
                } on FirebaseException catch (e, s) {
                  log('Firebase Error', error: e, stackTrace: s);
                }
              },
            ),
          if (_image != null)
            Image.network(
              _image ?? '',
              height: 80.0,
              fit: BoxFit.fitHeight,
            ),
          MaterialButton(
            onPressed: () async {
              if (_image == null ||
                  _title.text.isEmpty ||
                  _description.text.isEmpty) {
                return;
              }

              final store = FirebaseFirestore.instance;
              DocumentReference d = FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.email);

              await store.collection('blogs').add({
                'title': _title.text,
                'description': _description.text,
                'createdBy': d,
                'image': _image
              });
              Navigator.pop(context);
            },
            color: Colors.green,
            child: Text('Post'),
          ),
        ],
      ),
    );
  }
}
