// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

class UserCadastroView extends StatefulWidget {
  const UserCadastroView({super.key});

  @override
  State<UserCadastroView> createState() => _UserCadastroViewState();
}

class _UserCadastroViewState extends State<UserCadastroView> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nomeController = TextEditingController();
  TextEditingController sobrenomeController = TextEditingController();
  LoginViewModel loginVM = LoginViewModel();

  String? _validateNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'O nome é obrigatório';
    }
    return null;
  }

  String? _validateSobrenome(String? value) {
    if (value == null || value.isEmpty) {
      return 'O sobrenome é obrigatório';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    loginVM = Provider.of<LoginViewModel>(context, listen: false);
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
          children: [
            const SizedBox(height: 80),
            FadeInUp(
              duration: Duration(milliseconds: 1000),
              child: Text("Usuário",
                  style: TextStyle(color: Colors.white, fontSize: 40)),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              duration: Duration(milliseconds: 1300),
              child: Text("Informe seus dados",
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
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 40),
            FadeInUp(
              duration: const Duration(milliseconds: 1400),
              child: _buildTextField("Nome",
                  controller: nomeController,
                  validator: _validateNome,
                  icon: Icons.person),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 1400),
              child: _buildTextField("Sobrenome",
                  controller: sobrenomeController,
                  validator: _validateSobrenome,
                  icon: Icons.person_outline),
            ),
            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 30),
            _buildVoltar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {required TextEditingController controller,
      required String? Function(String?) validator,
      required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          hintStyle: const TextStyle(color: Colors.grey),
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
          if (_formKey.currentState?.validate() ?? false) {
            // Aqui você pode fazer algo com os dados:
            final nome = nomeController.text;
            final sobrenome = sobrenomeController.text;
            try {
              var res =
                  await loginVM.insertUsuario(nome: nome, sobrenome: sobrenome);
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Sucesso"),
                    content: Text("Cadastro Realizado Com Sucesso!"),
                    actions: [
                      TextButton(
                        onPressed: () => GoRouter.of(context).pop(),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                return await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Erro"),
                    content: Text("Ocorreu um erro inesperado."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            }
          }
        },
        height: 50,
        color: Colors.orange[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Center(
          child: Text("Continuar",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildVoltar() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Deseja voltar?", style: TextStyle(color: Colors.grey[700])),
          TextButton(
            onPressed: () {
              GoRouter.of(context).pop();
            },
            child: Text("Cancelar",
                style: TextStyle(
                    color: Colors.orange[900], fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
