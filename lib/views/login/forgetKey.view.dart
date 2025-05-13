// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:track_tcc_app/views/widgets/loading.widget.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

class RecuperacaoSenhaView extends StatefulWidget {
  const RecuperacaoSenhaView({super.key});

  @override
  RecuperacaoSenhaViewState createState() => RecuperacaoSenhaViewState();
}

class RecuperacaoSenhaViewState extends State<RecuperacaoSenhaView> {
  LoginViewModel login = LoginViewModel();
  TextEditingController emailController = TextEditingController();

  Future forgetKey(String email) async {
    var res = await login.forgetKey(email: email);

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.orange.shade900,
                Colors.orange.shade800,
                Colors.orange.shade400,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: const Text(
                        "Recuperar Senha",
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1300),
                      child: const Text(
                        "Digite seu e-mail para redefinir sua senha",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  // borderRadius: const BorderRadius.only(
                  //   topLeft: Radius.circular(60),
                  //   topRight: Radius.circular(60),
                  // ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 60),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: "E-mail",
                                prefixIcon: const Icon(Icons.email),
                                hintStyle: const TextStyle(color: Colors.grey),
                                // border: InputBorder.none,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1600),
                        child: MaterialButton(
                          onPressed: () async {
                            if (emailController.text.isNotEmpty) {
                              Dialogs.showLoading(context, null);

                              bool res = await forgetKey(emailController.text);

                              if (mounted) {
                                Navigator.pop(context);
                              }

                              if (res) {
                                if (mounted) {
                                  await Dialogs.showAlert(
                                      context: context,
                                      title: "Sucesso!",
                                      message:
                                          "O e-mail foi enviado com sucesso!");
                                }
                                if (res) {
                                  if (mounted) {
                                    GoRouter.of(context)
                                        .pushReplacement('/login');
                                  }
                                }
                              } else {
                                await Dialogs.showAlert(
                                    context: context,
                                    title: "Erro!",
                                    message:
                                        "Verifique os dados e tente novamente");
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Por favor, insira um e-mail válido."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          height: 50,
                          color: Colors.orange[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              "Enviar",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: TextButton(
                          onPressed: () {
                            GoRouter.of(context).pop();
                          },
                          child: Text(
                            "Voltar para Login",
                            style: TextStyle(
                                color: Colors.orange[900],
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
