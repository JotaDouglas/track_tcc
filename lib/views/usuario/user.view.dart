import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _nomeController = TextEditingController();
  final _fotoController = TextEditingController();
  bool _carregando = true;

  final _db = FirebaseDatabase.instance.ref();
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final snapshot = await _db.child('users/$_uid').get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      _nomeController.text = data['name'] ?? '';
      _fotoController.text = data['photoUrl'] ?? '';
    }

    setState(() {
      _carregando = false;
    });
  }

  Future<void> _salvarPerfil() async {
    await _db.child('users/$_uid').update({
      'name': _nomeController.text.trim(),
      'photoUrl': _fotoController.text.trim(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_fotoController.text),
                    onBackgroundImageError: (_, __) {},
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _fotoController,
                    decoration: const InputDecoration(
                      labelText: 'URL da Foto',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _salvarPerfil,
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ),
    );
  }
}
