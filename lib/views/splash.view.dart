// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/views/home/home.view.dart';
import 'package:track_tcc_app/views/login/login.view.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  LoginViewModel authViewModel = LoginViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future readUser() async {
    await authViewModel.loadUserFromPrefs();
  }

  // Verifica se o usuário já está autenticado
  void _checkLoginStatus() async {
    authViewModel = Provider.of<LoginViewModel>(context, listen: false);

    await authViewModel.loadUserFromPrefs();

    final user = authViewModel.loginUser;

    if (mounted) {
      if (user != null) {
        log("Redirecionando para HomeView");
        await readUser();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
          (Route<dynamic> route) => false,
        );
      } else {
        log("Redirecionando para LoginView");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
