import 'dart:async';
import 'dart:developer';

import 'package:blogger/models/blog_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlogFirebaseModel {
  final _blogStreamController = StreamController<List<BlogModel>>.broadcast();

  get blogs => _blogStreamController.stream;

  BlogFirebaseModel() {
    getBlogs();
  }

  getBlogs() async {
    final map = await FirebaseFirestore.instance.collection('blogs').get();
    for (var m in map.docs) {
      log('${m.data()}', name: 'Blog Data');
    }
  }
}
