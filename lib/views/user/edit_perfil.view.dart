import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

class EditarPerfilView extends StatefulWidget {
  const EditarPerfilView({super.key});

  @override
  State<EditarPerfilView> createState() => _EditarPerfilViewState();
}

class _EditarPerfilViewState extends State<EditarPerfilView> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController sobrenomeController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

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
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Sobrenome
            TextField(
              controller: sobrenomeController,
              decoration: InputDecoration(
                labelText: 'Sobrenome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Biografia
            TextField(
              controller: bioController,
              decoration: InputDecoration(
                labelText: 'Biografia',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // ação de salvar
                  final nome = nomeController.text.trim();
                  final sobrenome = sobrenomeController.text.trim();
                  final bio = bioController.text.trim();

                  // Exemplo: print no console
                  print('Nome: $nome $sobrenome\nBio: $bio');

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
    );
  }
}
