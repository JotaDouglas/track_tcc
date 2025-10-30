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
    final grupoVM = Provider.of<GrupoViewModel>(context, listen: false);
    grupoVM.carregarGrupos();
  }

  @override
  Widget build(BuildContext context) {
    final grupoVM = Provider.of<GrupoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Grupos',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
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
            backgroundColor: Colors.orange[900],
            heroTag: "search",
            icon: const Icon(Icons.group_add),
            label: const Text('Entrar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
            onPressed: () => context.pushNamed('grupo-entrar'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            backgroundColor: Colors.green,
            heroTag: 'create',
            icon: const Icon(Icons.add),
            label: const Text('Criar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
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
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                  ),
                  onTap: () async {
                    grupoVM.changeMembros(grupo.membros);
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
