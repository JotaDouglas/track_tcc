import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/grupo/grupo.viewmodel.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nomeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool aberto = false;

  @override
  Widget build(BuildContext context) {
    final grupoVM = Provider.of<GrupoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar novo grupo'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Observer(builder: (_) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nome do grupo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ex: Amigos do pedal',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Descrição',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  hintText: 'Adicione uma descrição (opcional)',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: aberto,
                title: const Text('Permitir que qualquer membro remova outros'),
                onChanged: (v) => setState(() => aberto = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: grupoVM.loading
                      ? null
                      : () async {
                          if (_nomeCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Informe o nome do grupo'),
                              ),
                            );
                            return;
                          }

                          final grupo = await grupoVM.criarGrupo(
                            _nomeCtrl.text.trim(),
                            descricao: _descCtrl.text.trim(),
                            aberto: aberto,
                          );

                          if (grupo != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Grupo "${grupo.nome}" criado!'),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                  child: grupoVM.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Criar grupo',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
