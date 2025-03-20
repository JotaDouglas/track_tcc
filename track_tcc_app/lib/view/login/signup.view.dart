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
    if (!_formKey.currentState!.validate()) {
      return false;
    }else{
      return true;
    }
  }

  Future _submit(String email, String password) async {
    User? logar =
        await login.createEmailAndPassword(email: email, password: password);
    if (logar?.uid != null) {
      return true;
    } else {
      return false;
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O e-mail é obrigatório';
    }
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
    if (value == null || value.isEmpty) {
      return 'A senha é obrigatória';
    }
    if (value != passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        reverse: true,
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
      decoration: const BoxDecoration(
        color: Colors.white,
        // borderRadius:  BorderRadius.only(
        //     topLeft: Radius.circular(60), topRight: Radius.circular(60)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 40),
            FadeInUp(
                duration: const Duration(milliseconds: 1400),
                child: _buildTextField("E-mail",
                    icon: Icons.email,
                    controller: emailController,
                    validator: _validateEmail)),
            FadeInUp(
              duration: const Duration(milliseconds: 1400),
              child: _buildTextField("Senha",
                  icon: Icons.lock,
                  controller: passwordController,
                  isPassword: true,
                  validator: _validatePassword),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 1400),
              child: _buildTextField("Confirme a senha",
                  icon: Icons.lock,
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
      required String? Function(String?) validator,
      required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          hintStyle: const TextStyle(color: Colors.grey),
          // border: InputBorder.none,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1600),
      child: MaterialButton(
        onPressed: () async {
          try {
            var validate = await _validateAndSubmit(
                emailController.text, passwordController.text);

            if (!validate) return;

            if (!mounted) return;

            Dialogs.showLoading(context, null);
            //123345
            var criar =
                await _submit(emailController.text, passwordController.text);
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
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            if (mounted) {
              await Dialogs.showAlert(
                context: context,
                title: "Erro!",
                message:
                    "Ocorreu um erro ao criar sua conta. Verifique a sua conexão e suas informações.",
              );
            }
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
            child: Text("Fazer login",
                style: TextStyle(
                    color: Colors.orange[900], fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
