import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/viewmodel/amizade.viewmodel.dart';

class BuscarAmigosView extends StatefulWidget {
  const BuscarAmigosView({super.key});

  @override
  State<BuscarAmigosView> createState() => _BuscarAmigosViewState();
}

class _BuscarAmigosViewState extends State<BuscarAmigosView> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  List<Map<String, dynamic>> _usuarios = [];
  AmizadeViewModel amizadeVM = AmizadeViewModel();

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Delay para garantir que o contexto esteja disponível
    Future.microtask(() {
      amizadeVM = Provider.of<AmizadeViewModel>(context, listen: false);

      readUsers();
    });
  }

  readUsers() async {
    await amizadeVM.readMyFriends();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _buscarUsuarios(_searchController.text.trim());
    });
  }

  Future<void> _buscarUsuarios(String termo) async {
    setState(() => _isLoading = true);

    final data = await amizadeVM.buscarAmigos(termo); // sua busca de usuários

    // Sua lista de amizades já carregada (amizadeVM.friends)
    final amizades = amizadeVM.friends;

    // ID do usuário logado
    final meuId = supabase.auth.currentUser!.id;

    // Cria um mapa para lookup rápido: key = id do usuário buscado, value = status da amizade
    final Map<String, String> statusPorUsuario = {};

    for (final amizade in amizades) {
      final outroId = amizade['usuario_id'] == meuId
          ? amizade['amigo_id']
          : amizade['usuario_id'];

      statusPorUsuario[outroId] = amizade['status'];
    }

    final List<Map<String, dynamic>> usuariosAtualizados = data.map((user) {
      final userId = user['user_id']; // ou 'id_usuario', conforme seu retorno

      final statusAmizade = statusPorUsuario[userId] ?? 'nenhum';

      return {
        ...user,
        'statusAmizade': statusAmizade,
        'ja_solicitado': statusAmizade, // booleano pra facilitar
      };
    }).toList();

    setState(() {
      _usuarios = usuariosAtualizados;
      _isLoading = false;
    });
  }

  Future _cancelarSolicitacao(String amigoId, String termo) async {
    final meuId = supabase.auth.currentUser?.id;
    if (meuId == null) return;

    await amizadeVM.cancelarSolicitacaoAmizade(amigoId);

    _buscarUsuarios(termo);
  }

  Future<void> _enviarSolicitacao(String amigoId, String termo) async {
    final meuId = supabase.auth.currentUser?.id;
    if (meuId == null) return;

    bool data = await amizadeVM.enviarSolicitacaoAmizade(meuId, amigoId);

    if (data) {
      await amizadeVM.readMyFriends();
      setState(() {
        _usuarios = _usuarios.map((user) {
          if (user['id'] == amigoId) {
            return {...user, 'ja_solicitado': true};
          }
          return user;
        }).toList();
      });

      _buscarUsuarios(termo);
    }
  }

  @override
  Widget build(BuildContext context) {
    amizadeVM = Provider.of<AmizadeViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BUSCAR AMIGOS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Digite o nome ou sobrenome...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _usuarios.length,
              itemBuilder: (context, index) {
                final usuario = _usuarios[index];
                final nome = '${usuario['nome']} ${usuario['sobrenome']}';
                final uid = usuario['user_id'];
                final status = usuario['ja_solicitado'] ?? false;

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(nome),
                  subtitle: Text(uid, overflow: TextOverflow.ellipsis),
                  trailing: ElevatedButton(
                    onPressed: status == 'pendente'
                        ? () => _cancelarSolicitacao(uid, _searchController.text)
                        : () => _enviarSolicitacao(uid, _searchController.text),
                    child: Text(status == 'pendente'
                        ? 'Solicitado'
                        : status == 'aceito'
                            ? "Amigos"
                            : 'Adicionar'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
