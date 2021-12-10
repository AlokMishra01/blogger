import 'dart:developer';

import 'package:blogger/models/blog_model.dart';
import 'package:blogger/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _getUser();
    getBlogs();
  }

  getBlogs() async {
    final map = await FirebaseFirestore.instance.collection('blogs').get();
    for (var m in map.docs) {
      log('${m.data()}', name: 'Blog Data');
      DocumentReference d = m.data()['createdBy'];
      List<DocumentReference> l = m.data()['likes'];
      final u = await d.get();
      log('${u.data()}', name: 'Blog Data Created By');
    }
  }

  _getUser() async {
    var map = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get();
    _user = UserModel.fromJson(map);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _user != null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    _user?.image ?? '',
                  ),
                ),
              )
            : const CircularProgressIndicator(),
        title: Text(
          _user != null ? _user?.name ?? '' : 'Loading...',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showModal,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'ERROR!',
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.red,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.only(
              right: 16.0,
              left: 16.0,
              top: 16.0,
              bottom: 80.0,
            ),
            itemBuilder: (_, i) {
              log('${snapshot.data?.docs[i].data()}', name: 'DATA');
              final data = snapshot.data?.docs[i].data();
              final blog = BlogModel.fromJson(data);
              DocumentReference user = snapshot.data?.docs[i].get('createdBy');
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16.0),
                      ),
                      child: Image.network(
                        blog.image ?? '',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog.title ?? '',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            blog.description ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          FutureBuilder(
                            future: user.get(),
                            builder: (_, s) {
                              if (s.hasData) {
                                final u = UserModel.fromJson(s.data);
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      u.image ?? '',
                                    ),
                                  ),
                                  title: Text(u.name ?? ''),
                                  trailing: IconButton(
                                    onPressed: () {
                                      final store = FirebaseFirestore.instance;
                                      store
                                          .collection('blogs')
                                          .doc(snapshot.data?.docs[i].id)
                                          .delete();
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, i) {
              return const SizedBox(height: 8.0);
            },
            itemCount: snapshot.data?.size ?? 0,
          );
        },
      ),
    );
  }

  final _title = TextEditingController();
  final _description = TextEditingController();
  _showModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _description,
              minLines: 5,
              maxLines: 8,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            MaterialButton(
              onPressed: () async {
                final store = FirebaseFirestore.instance;
                DocumentReference d = FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.email);

                await store.collection('blogs').add({
                  'title': _title.text,
                  'description': _description.text,
                  'createdBy': d,
                  'image': 'https://miro.medium.com/max/2000/0*_hVZ_qoWPxzQK3ws'
                });
                Navigator.pop(context);
              },
              color: Colors.green,
              child: Text('Post'),
            ),
          ],
        );
      },
    );
  }
}
