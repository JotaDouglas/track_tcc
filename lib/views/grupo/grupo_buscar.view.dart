import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/grupo/grupo.viewmodel.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _codigoCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final grupoVM = Provider.of<GrupoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar em um grupo'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Observer(builder: (_) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Digite o código do grupo:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _codigoCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Ex: AB12CD',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.group_add, color: Colors.white),
                  label: grupoVM.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Entrar no grupo',
                          style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: grupoVM.loading
                      ? null
                      : () async {
                          final codigo = _codigoCtrl.text.trim();
                          if (codigo.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Digite um código válido'),
                              ),
                            );
                            return;
                          }

                          final sucesso =
                              await grupoVM.entrarPorCodigo(codigo);

                          if (!mounted) return;

                          if (sucesso) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Você entrou no grupo com sucesso!'),
                              ),
                            );
                            Navigator.pop(context); // volta para a lista
                            grupoVM.carregarGrupos(); // atualiza
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(grupoVM.errorMessage ??
                                    'Erro ao entrar no grupo.'),
                              ),
                            );
                          }
                        },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
