import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:track_tcc_app/views/widgets/loading.widget.dart';

class CadastroStepperView extends StatefulWidget {
  const CadastroStepperView({super.key});

  @override
  State<CadastroStepperView> createState() => _CadastroStepperViewState();
}

class _CadastroStepperViewState extends State<CadastroStepperView> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  GlobalKey<State<StatefulWidget>>? key;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();

  Future<void> _onStepContinue() async {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep += 1);
      }
    } else if (_currentStep == 1) {
      if (nameController.text.trim().isNotEmpty) {
        setState(() => _currentStep += 1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Digite seu nome completo.")),
        );
      }
    } else {
      Dialogs.showLoading(context, key);

      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final uid = userCredential.user?.uid;

        if (uid != null) {
          await _db.child('users/$uid').set({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
          });

          if (mounted) Navigator.pop(context);

          if (mounted) {
            await Dialogs.showAlert(
              context: context,
              title: "Sucesso!",
              message: "Sua conta foi criada com sucesso!",
            );
            GoRouter.of(context).pushReplacement('/login');
          }
        } else {
          throw Exception("UID nulo após criação.");
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          await Dialogs.showAlert(
            context: context,
            title: "Erro",
            message: "Erro ao criar conta: ${e.toString()}",
          );
        }
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Z E L O",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[900],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          controlsBuilder: (context, details) {
            return Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: const Text('Continuar'),
                ),
                const SizedBox(width: 10),
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Voltar'),
                  ),
              ],
            );
          },
          steps: [
            Step(
              title: Text(_currentStep == 0 ? "Informações da conta" : ""),
              content: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      label: "E-mail",
                      controller: emailController,
                      icon: Icons.email,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Informe o e-mail'
                          : null,
                    ),
                    _buildTextField(
                      label: "Senha",
                      controller: passwordController,
                      icon: Icons.lock,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a senha';
                        }
                        if (value.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      label: "Confirmar Senha",
                      controller: confirmPasswordController,
                      icon: Icons.lock,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirme sua senha';
                        }
                        if (value != passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: Text(_currentStep == 1 ? "Dados pessoais" : ""),
              content: _buildTextField(
                label: "Nome completo",
                controller: nameController,
                icon: Icons.person,
                validator: (_) => null,
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: Text(_currentStep == 1 ? "Finalizar" : ""),
              content:
                  const Text("Clique em Continuar para concluir o cadastro."),
              isActive: _currentStep >= 2,
              state: _currentStep == 2 ? StepState.indexed : StepState.disabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
