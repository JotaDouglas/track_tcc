import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/utils/validators.util.dart';
import 'package:track_tcc_app/views/widgets/loading.widget.dart';
import 'package:track_tcc_app/views/widgets/login/auth_header.widget.dart';
import 'package:track_tcc_app/views/widgets/login/auth_navigation_link.widget.dart';
import 'package:track_tcc_app/views/widgets/login/auth_text_field.widget.dart';
import 'package:track_tcc_app/views/widgets/login/primary_button.widget.dart';
import 'package:track_tcc_app/views/widgets/login/terms_checkbox.widget.dart';
import 'package:track_tcc_app/views/widgets/login/terms_dialog.widget.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  CadastroViewState createState() => CadastroViewState();
}

class CadastroViewState extends State<CadastroView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late LoginViewModel _loginViewModel;
  bool _aceitouTermos = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _validateAndSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    return true;
  }

  Future<bool> _submit() async {
    return await _loginViewModel.createEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _handleCadastro() async {
    try {
      if (!_aceitouTermos) {
        await Dialogs.showAlert(
          context: context,
          title: "Atenção!",
          message: "Você precisa aceitar os termos de responsabilidade para continuar.",
        );
        return;
      }

      final isValid = await _validateAndSubmit();
      if (!isValid) return;

      if (!mounted) return;

      Dialogs.showLoading(context, null);

      final sucesso = await _submit();

      if (sucesso) {
        if (mounted) {
          await Dialogs.showAlert(
            context: context,
            title: "Sucesso!",
            message: "Sua conta foi criada com sucesso!",
          );
        }

        if (mounted && Navigator.canPop(context)) {
          GoRouter.of(context).pushReplacement('/login/register/name');
        }
      } else {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (mounted) {
          await Dialogs.showAlert(
            context: context,
            title: "Erro!",
            message: "Ocorreu um erro ao criar sua conta. Verifique suas informações e tente novamente.",
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
          message: "Ocorreu um erro ao criar sua conta. Verifique a sua conexão e suas informações.",
        );
      }
    }
  }

  void _handleTermsAccept() {
    setState(() {
      _aceitouTermos = true;
    });
  }

  void _handleTermsToggle(bool value) {
    setState(() {
      _aceitouTermos = value;
    });
  }

  void _showTermsDialog() {
    TermsDialog.show(
      context: context,
      onAccept: _handleTermsAccept,
    );
  }

  @override
  Widget build(BuildContext context) {
    _loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        reverse: true,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const AuthHeader(
                title: "Cadastro",
                subtitle: "Crie sua conta",
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 40),
                      AuthTextField(
                        hintText: "E-mail",
                        icon: Icons.email,
                        controller: _emailController,
                        validator: Validators.validateEmail,
                      ),
                      AuthTextField(
                        hintText: "Senha",
                        icon: Icons.lock,
                        controller: _passwordController,
                        isPassword: true,
                        validator: Validators.validatePassword,
                      ),
                      AuthTextField(
                        hintText: "Confirme a senha",
                        icon: Icons.lock,
                        controller: _confirmPasswordController,
                        isPassword: true,
                        validator: (value) => Validators.validateConfirmPassword(
                          value,
                          _passwordController.text,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TermsCheckbox(
                        value: _aceitouTermos,
                        onChanged: _handleTermsToggle,
                        onTermsTap: _showTermsDialog,
                      ),
                      const SizedBox(height: 40),
                      PrimaryButton(
                        text: "Cadastrar",
                        onPressed: _handleCadastro,
                      ),
                      const SizedBox(height: 50),
                      AuthNavigationLink(
                        text: "Já tem uma conta?",
                        linkText: "Fazer login",
                        onPressed: () => GoRouter.of(context).pop(),
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
