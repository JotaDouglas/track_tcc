import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:track_tcc_app/utils/validators.util.dart';
import 'package:track_tcc_app/views/widgets/loading.widget.dart';
import 'package:track_tcc_app/views/widgets/login/auth_header.widget.dart';
import 'package:track_tcc_app/views/widgets/login/auth_navigation_link.widget.dart';
import 'package:track_tcc_app/views/widgets/login/auth_text_field.widget.dart';
import 'package:track_tcc_app/views/widgets/login/primary_button.widget.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(LoginViewModel authViewModel) async {
    if (_formKey.currentState!.validate()) {
      Dialogs.showLoading(context, null);

      await authViewModel.loginWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (authViewModel.loginUser != null) {
        log("Usuário já logado: ${authViewModel.loginUser?.email}");
        if (mounted) {
          GoRouter.of(context).pushReplacement('/home');
        }
      } else {
        log("Nenhum usuário logado.");

        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (authViewModel.errorMessage != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Verifique os seus dados e a conexão com a internet."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(
              title: "Zelo App",
              subtitle: "Tranquilidade que te acompanha",
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 40),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1400),
                      child: Form(
                        key: _formKey,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: <Widget>[
                              AuthTextField(
                                hintText: "E-mail",
                                icon: Icons.email,
                                controller: _emailController,
                                validator: Validators.validateEmail,
                                animationDelay: 0,
                              ),
                              const SizedBox(height: 10),
                              AuthTextField(
                                hintText: "Senha",
                                icon: Icons.lock,
                                controller: _passwordController,
                                isPassword: true,
                                validator: Validators.validateLoginPassword,
                                animationDelay: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              GoRouter.of(context).push('/login/forgot');
                            },
                            child: Text(
                              "Esqueceu a senha?",
                              style: TextStyle(
                                color: Colors.orange[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    PrimaryButton(
                      text: "Login",
                      onPressed: () => _handleLogin(authViewModel),
                    ),
                    const SizedBox(height: 50),
                    AuthNavigationLink(
                      text: "Ainda não é membro?",
                      linkText: " Inscreva-se",
                      onPressed: () {
                        GoRouter.of(context).push('/login/register');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
