import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/grupo/grupo.viewmodel.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  @override
  void initState() {
    super.initState();
    final grupoVM = context.read<GrupoViewModel>();
    grupoVM.carregarGrupos();
  }

  @override
  Widget build(BuildContext context) {
    final grupoVM = Provider.of<GrupoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus grupos'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => grupoVM.carregarGrupos(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            backgroundColor: Colors.teal,
            heroTag: "search",
            icon: const Icon(Icons.group_add),
            label: const Text('Entrar'),
            onPressed: () => context.pushNamed('grupo-entrar'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            backgroundColor: Colors.teal,
            heroTag: 'create',
            icon: const Icon(Icons.add),
            label: const Text('Criar'),
            onPressed: () => context.pushNamed('grupo-criar'),
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          if (grupoVM.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (grupoVM.grupos.isEmpty) {
            return const Center(
              child: Text('Você ainda não participa de nenhum grupo.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: grupoVM.grupos.length,
            itemBuilder: (_, i) {
              final grupo = grupoVM.grupos[i];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(grupo.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(grupo.descricao ?? 'Sem descrição'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.teal),
                  onTap: () {
                    context.pushNamed(
                      'grupo-detalhe',
                      extra: {
                        'id': grupo.id,
                        'nome': grupo.nome,
                        'codigo': grupo.codigo,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
