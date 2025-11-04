import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:track_tcc_app/viewmodel/cerca.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/grupo/grupo.viewmodel.dart';
import 'package:track_tcc_app/views/cerca/cerca.map.view.dart';

class CercaGrupoListScreen extends StatefulWidget {
  const CercaGrupoListScreen({super.key});

  @override
  State<CercaGrupoListScreen> createState() => _CercaGrupoListScreenState();
}

class _CercaGrupoListScreenState extends State<CercaGrupoListScreen> {
  bool _inited = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _inited = true;
      _initLoad();
    }
  }

  Future<void> _initLoad() async {
    try {
      // tenta ler o GrupoViewModel — se não estiver registrado, lança e mostra erro
      final grupoVM = context.read<GrupoViewModel>();
      if (grupoVM.grupos.isEmpty) {
        await grupoVM.carregarGrupos();
      }
      // opcional: pré-carregar dados de cercas? não aqui
    } catch (e) {
      setState(() => _error = 'Erro ao inicializar: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of com listen true para rebuild automático
    late final GrupoViewModel grupoVM;
    try {
      grupoVM = context.watch<GrupoViewModel>();
    } catch (e) {
      // Se não estiver registrado, mostramos mensagem amigável
      return Scaffold(
        appBar: AppBar(title: const Text('Cercas por Grupo')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'GrupoViewModel não encontrado via Provider.\n'
              'Certifique-se de que você registrou Provider<GrupoViewModel> no main.dart.\n\n'
              'Erro: ${e.toString()}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final cercaVM = context.read<CercaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cercas por Grupo'),
        backgroundColor: Colors.orange[900],
      ),
      body: _buildBody(grupoVM, cercaVM),
    );
  }

  Widget _buildBody(GrupoViewModel grupoVM, CercaViewModel cercaVM) {
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (grupoVM.loading && grupoVM.grupos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (grupoVM.grupos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group_off, size: 72, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Você ainda não participa de nenhum grupo.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => grupoVM.carregarGrupos(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => grupoVM.carregarGrupos(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: grupoVM.grupos.length,
        itemBuilder: (context, index) {
          final grupo = grupoVM.grupos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.group, color: Colors.orange),
              title: Text(grupo.nome),
              subtitle: Text(grupo.descricao ?? ''),
              trailing: const Icon(Icons.map),
              onTap: () async {
                try {
                  // Carrega as cercas do grupo selecionado (atualiza CercaViewModel)
                  await cercaVM.carregarCercasGrupo(grupo.id, grupo.nome);

                  // Passe apenas os dados necessários para a rota do mapa.
                  // Recomendo configurar a rota nomeada 'cerca-mapa' no GoRouter.
                  if(!mounted) return;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CercaMapView(grupoId: grupo.id, grupoNome: grupo.nome,)));
                } catch (e) {
                  // tratamento amigável
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao abrir mapa: ${e.toString()}')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
