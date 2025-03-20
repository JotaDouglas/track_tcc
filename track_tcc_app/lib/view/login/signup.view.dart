import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:track_tcc_app/view/login/login.view.dart';
import 'package:track_tcc_app/view/widgets/loading.widget.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  CadastroViewState createState() => CadastroViewState();
}

class CadastroViewState extends State<CadastroView> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  LoginViewModel login = LoginViewModel();

  Future _validateAndSubmit(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      log('Cadastro válido!');
      User? logar =
          await login.createEmailAndPassword(email: email, password: password);
      if (logar?.uid != null) {
        return true;
      } else {
        return false;
      }
    }
  }

  String? _validateEmail(String? value) {
    // if (value == null || value.isEmpty) {
    //   return 'O e-mail é obrigatório';
    // }
    // final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\$');
    // if (!emailRegex.hasMatch(value)) {
    //   return 'Digite um e-mail válido';
    // }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha é obrigatória';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 80),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: const Text("Cadastro",
                  style: TextStyle(color: Colors.white, fontSize: 40)),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              duration: const Duration(milliseconds: 1300),
              child: const Text("Crie sua conta",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(60), topRight: Radius.circular(60)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 60),
            FadeInUp(
                duration: const Duration(milliseconds: 1400),
                child: _buildTextField("E-mail",
                    controller: emailController, validator: _validateEmail)),
            FadeInUp(
              duration: const Duration(milliseconds: 1400),
              child: _buildTextField("Senha",
                  controller: passwordController,
                  isPassword: true,
                  validator: _validatePassword),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 1400),
              child: _buildTextField("Confirme a senha",
                  controller: confirmPasswordController,
                  isPassword: true,
                  validator: _validateConfirmPassword),
            ),
            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 50),
            _buildLoginRedirect(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {bool isPassword = false,
      required TextEditingController controller,
      required String? Function(String?) validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1600),
      child: MaterialButton(
        onPressed: () async {
          if (!mounted)
            return; // Verifica se o widget ainda está na árvore de widgets

          Dialogs.showLoading(context, null);

          try {
            var criar = await _validateAndSubmit(
                emailController.text, passwordController.text);
            if (criar) {
              if (mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }

              if (mounted) {
                await Dialogs.showAlert(
                    context: context,
                    title: "Sucesso!",
                    message: "Sua conta foi criada com sucesso!");
              }

              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              }
            } else {
              if (mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              if (mounted) {
                await Dialogs.showAlert(
                  context: context,
                  title: "Erro!",
                  message:
                      "Ocorreu um erro ao criar sua conta. Verifique suas informações e tente novamente.",
                );
              }
            }
          } catch (e) {
            log("Erro ao validar e enviar: $e");
          }
        },
        height: 50,
        color: Colors.orange[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Center(
          child: Text("Cadastrar",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Já tem uma conta?", style: TextStyle(color: Colors.grey[700])),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginView()));
            },
            child:
                const Text(" Faça login", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
