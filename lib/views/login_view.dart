import 'dart:developer';

import 'package:blogger/constants/app_colors.dart';
import 'package:blogger/models/user_model.dart';
import 'package:blogger/views/home_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: InkWell(
          onTap: _googleLogin,
          child: CircleAvatar(
            radius: 36.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36.0),
              child: Image.asset(
                'assets/images/google.jpg',
              ),
            ),
          ),
        ),
      ),
    );
  }

  _googleLogin() async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'profile',
      ],
    );
    try {
      await googleSignIn.signOut();
      GoogleSignInAccount? account = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await account?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential u = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (u.user?.email != null) {
        final store = FirebaseFirestore.instance;
        await store.collection('users').doc(u.user?.email ?? '').set(UserModel(
              name: u.user?.displayName ?? '',
              email: u.user?.email ?? '',
              image: u.user?.photoURL ?? '',
            ).toJson());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeView(),
          ),
        );
      }
    } catch (error, stacktrace) {
      log(
        'Google Sign Error',
        error: error,
        stackTrace: stacktrace,
      );
    }
  }
}
