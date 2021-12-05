import 'dart:async';

import 'package:blogger/constants/app_colors.dart';
import 'package:blogger/views/home_view.dart';
import 'package:blogger/views/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 2),
      _checkLogin,
    );
  }

  _checkLogin() async {
    User? u = _firebaseAuth.currentUser;
    if (u != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeView(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginView(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Image.asset(
          'assets/images/blogger.jpg',
          height: 120.0,
          width: 120.0,
        ),
      ),
    );
  }
}
