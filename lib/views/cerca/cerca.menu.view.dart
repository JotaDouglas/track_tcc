import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
  @override
  void initState() {
    super.initState();
    // Carrega os dados assim que a tela é inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  Future<void> _carregarDados() async {
    try {
      final grupoVM = Provider.of<GrupoViewModel>(context, listen: false);
      // Sempre busca dados atualizados do Supabase ao acessar a tela
      await grupoVM.carregarGrupos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar grupos: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of com listen true para rebuild automático
    final grupoVM = Provider.of<GrupoViewModel>(context, listen: false);

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
    return Observer(builder: (context) {
      // Exibe o loading quando está carregando e não há grupos ainda
      if (grupoVM.loading && grupoVM.grupos.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      // Exibe erro se houver
      if (grupoVM.errorMessage != null && grupoVM.grupos.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 72, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                'Erro: ${grupoVM.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _carregarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
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
                onPressed: _carregarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _carregarDados,
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
                    if (!mounted) return;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CercaMapView(
                                  grupoId: grupo.id,
                                  grupoNome: grupo.nome,
                                )));
                  } catch (e) {
                    // tratamento amigável
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Erro ao abrir mapa: ${e.toString()}')),
                    );
                  }
                },
              ),
            );
          },
        ),
      );
    });
  }
}
