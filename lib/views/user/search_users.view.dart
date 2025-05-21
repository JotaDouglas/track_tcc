import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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
    final currentUserId = supabase.auth.currentUser?.id;

    if (termo.isEmpty || currentUserId == null) {
      setState(() => _usuarios = []);
      return;
    }

    setState(() => _isLoading = true);

    final response = await supabase
        .from('usuarios')
        .select('id_usuario, nome, sobrenome, biografia')
        .or('nome.ilike.%$termo%,sobrenome.ilike.%$termo%')
        .neq('user_id', currentUserId);

    final data = List<Map<String, dynamic>>.from(response);

    // for (final usuario in data) {
    //   final check = await supabase
    //       .from('friend_requests')
    //       .select()
    //       .eq('sender_id', currentUserId)
    //       .eq('receiver_id', usuario['id_usuario'])
    //       .eq('status', 'pending')
    //       .maybeSingle();

    //   usuario['ja_solicitado'] = check != null;
    // }

    setState(() {
      _usuarios = data;
      _isLoading = false;
    });
  }

  Future<void> _enviarSolicitacao(String receiverId) async {
    final senderId = supabase.auth.currentUser?.id;
    if (senderId == null) return;

    await supabase.from('friend_requests').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': 'pending',
    });
    setState(() {
      _usuarios = _usuarios.map((user) {
        if (user['id'] == receiverId) {
          return {...user, 'ja_solicitado': true};
        }
        return user;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                final bio = usuario['biografia'] ?? '';
                final jaSolicitado = usuario['ja_solicitado'] ?? false;

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(nome),
                  subtitle: Text(
                    bio,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: ElevatedButton(
                    onPressed: jaSolicitado
                        ? null
                        : () => _enviarSolicitacao(usuario['id_usuario']),
                    child: Text(jaSolicitado ? 'Solicitado' : 'Adicionar'),
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
