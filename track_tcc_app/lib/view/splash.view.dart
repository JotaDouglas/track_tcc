// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/view/home/home.view.dart';
import 'package:track_tcc_app/view/login/login.view.dart';
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
    final authViewModel = Provider.of<LoginViewModel>(context, listen: false);
    _checkLoginStatus();
  }

  Future readUser()async{
    await authViewModel.loadUserFromPrefs();
  }

  // Verifica se o usuário já está autenticado
  void _checkLoginStatus() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    await Future.delayed(const Duration(seconds: 2)); // Simula carregamento

    if (mounted) {
      if (user != null) {
        await readUser();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
          (Route<dynamic> route) => false, // Remove todas as rotas anteriores
        );
      } else {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
            (Route<dynamic> route) => false, // Remove todas as rotas anteriores
          );
        }
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
