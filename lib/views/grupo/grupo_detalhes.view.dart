import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:track_tcc_app/model/grupo/membros.model.dart';
import 'package:track_tcc_app/viewmodel/grupo/grupo.viewmodel.dart';

class GroupDetailScreen extends StatefulWidget {
  final String? grupoId;
  final String? nomeGrupo;
  final String? codigo;

  const GroupDetailScreen({
    super.key,
    this.grupoId,
    this.nomeGrupo,
    this.codigo,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    // se desejar, carregue os membros ao abrir
    // context.read<GrupoViewModel>().carregarMembros(widget.grupoId);
  }

  @override
  Widget build(BuildContext context) {
    final grupoVM = Provider.of<GrupoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeGrupo ?? "Sem Nome"),
        backgroundColor: Colors.teal,
      ),
      body: Observer(builder: (_) {
        if (grupoVM.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final membros = grupoVM
            .members; // supondo que exista o ObservableList<GroupMember> members

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.teal.shade50,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Código: ${widget.codigo}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.teal),
                    onPressed: () {
                      Share.share(
                          'Entre no grupo ${widget.nomeGrupo} com o código: ${widget.codigo}');
                    },
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Membros do grupo:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: membros.length,
                itemBuilder: (_, i) {
                  final membro = membros[i];
                  return _buildMemberTile(context, grupoVM, membro);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMemberTile(
      BuildContext context, GrupoViewModel grupoVM, GroupMember membro) {
    final userId = grupoVM.userId;
    final podeRemover =
        membro.userId != userId; // simples — refine com papel/admin

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          membro.userId,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Papel: ${membro.papel}'),
        trailing: podeRemover
            ? IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Remover membro'),
                      content: const Text(
                          'Tem certeza que deseja remover este membro do grupo?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Remover'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await grupoVM.removerMembro(widget.grupoId ?? 'sem id', membro.userId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membro removido')),
                      );
                    }
                  }
                },
              )
            : null,
      ),
    );
  }
}
