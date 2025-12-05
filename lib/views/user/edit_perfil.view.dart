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
                        bool sucesso = false;

                        if (user!.id == 0) {
                          sucesso = await loginVM.insertUsuario(
                            nome: nome,
                            sobrenome: sobrenome,
                            uuid: user.uidUsuario,
                          );
                        } else {
                          sucesso = await loginVM.updateUsuario(
                            userId: user.id!,
                            nome: nome,
                            sobrenome: sobrenome,
                            biografia: bio,
                          );
                        }

                        Navigator.pop(context); // fecha o loading (importante)

                        if (!sucesso) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Não foi possível atualizar o perfil.")),
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
                                      GoRouter.of(context).go('/home'),
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
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: corPrincipal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Atualizar',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 48),

              // Divisor
              const Divider(thickness: 1),
              const SizedBox(height: 16),

              // Texto de aviso
              const Text(
                'Zona de Perigo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta ação é irreversível e excluirá permanentemente sua conta.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Botão Excluir Conta
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    // Primeira confirmação
                    final confirmacao1 = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Excluir Conta'),
                        content: const Text(
                          'Você tem certeza que deseja excluir sua conta? '
                          'Esta ação não pode ser desfeita e todos os seus dados serão perdidos.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Continuar'),
                          ),
                        ],
                      ),
                    );

                    if (confirmacao1 != true) return;

                    // Segunda confirmação
                    final confirmacao2 = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Confirmação Final',
                          style: TextStyle(color: Colors.red),
                        ),
                        content: const Text(
                          'Esta é sua última chance. Deseja realmente excluir sua conta permanentemente?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Sim, excluir minha conta',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmacao2 != true) return;

                    try {
                      // Mostra loading
                      Dialogs.showLoading(context, null);

                      // Chama o método de exclusão
                      final sucesso = await loginVM.deleteUsuario();

                      // Fecha o loading
                      Navigator.pop(context);

                      if (sucesso) {
                        if (mounted) {
                          // Mostra mensagem de sucesso e redireciona para login
                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => AlertDialog(
                              title: const Text("Conta Excluída"),
                              content: const Text(
                                "Sua conta foi excluída com sucesso.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    GoRouter.of(context).go('/');
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Não foi possível excluir a conta. Tente novamente.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // Fecha o loading em caso de erro
                      Navigator.pop(context);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Ocorreu um erro ao excluir a conta.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.red, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Excluir Conta',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
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
