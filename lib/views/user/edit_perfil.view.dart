// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';
import 'package:track_tcc_app/views/widgets/loading.widget.dart';

class EditarPerfilView extends StatefulWidget {
  const EditarPerfilView({super.key});

  @override
  State<EditarPerfilView> createState() => _EditarPerfilViewState();
}

class _EditarPerfilViewState extends State<EditarPerfilView> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  LoginViewModel loginVM = LoginViewModel();

  @override
  void dispose() {
    nomeController.dispose();
    sobrenomeController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final corPrincipal = Colors.orange[900];
    final authViewModel = Provider.of<LoginViewModel>(context);
    loginVM = Provider.of<LoginViewModel>(context, listen: false);
    var user = authViewModel.loginUser;

    nomeController.text = user?.username ?? '';
    sobrenomeController.text = user?.sobrenome ?? '';
    bioController.text = user?.bio ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: corPrincipal,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Foto ilustrativa
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orange[900],
                child: Icon(Icons.camera_alt, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 24),

              // Campo Nome
              TextFormField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                maxLength: 30,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  final regex = RegExp(r"^[a-zA-ZÀ-ÿ\s]{1,30}$");
                  if (!regex.hasMatch(value.trim())) {
                    return 'Use apenas letras (máx. 30 caracteres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Sobrenome
              TextFormField(
                controller: sobrenomeController,
                decoration: const InputDecoration(
                  labelText: 'Sobrenome',
                  border: OutlineInputBorder(),
                ),
                maxLength: 30,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sobrenome é obrigatório';
                  }
                  final regex = RegExp(r"^[a-zA-ZÀ-ÿ\s]{1,30}$");
                  if (!regex.hasMatch(value.trim())) {
                    return 'Use apenas letras (máx. 30 caracteres)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo Biografia
              TextFormField(
                controller: bioController,
                decoration: InputDecoration(
                  labelText: 'Biografia',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                maxLength: 250,
              ),
              const SizedBox(height: 32),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // ação de salvar
                    final nome = nomeController.text.trim();
                    final sobrenome = sobrenomeController.text.trim();
                    final bio = bioController.text.trim();

                    try {
                      if (_formKey.currentState?.validate() ?? false) {
                        Dialogs.showLoading(context, null);

                        final sucesso = await loginVM.updateUsuario(
                          userId: user!.id!,
                          nome: nome,
                          sobrenome: sobrenome,
                          biografia: bio,
                        );

                        Navigator.pop(context); // fecha o loading (importante)

                        if (!sucesso) {
                          if (mounted) {
                            await showDialog(
                              context: context,
                              builder: (_) => const AlertDialog(
                                title: Text("Erro"),
                                content: Text(
                                    "Não foi possível atualizar o perfil."),
                              ),
                            );
                          }
                          return;
                        }

                        if (mounted) {
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Sucesso"),
                              content:
                                  const Text("Perfil atualizado com sucesso!"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      GoRouter.of(context).push('/home'),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // fecha o loading em caso de erro também
                      Navigator.pop(context);

                      if (mounted) {
                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Erro"),
                            content: const Text("Ocorreu um erro inesperado."),
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

                    // Exemplo: print no console
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Perfil atualizado!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corPrincipal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Salvar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
