import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocalizacoesPage extends StatefulWidget {
  const LocalizacoesPage({super.key});

  @override
  State<LocalizacoesPage> createState() => _LocalizacoesPageState();
}

class _LocalizacoesPageState extends State<LocalizacoesPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> localizacoes = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _setupRealtime();
  }

  void _fetchData() async {
    final response = await _supabase
        .from('localizacoes')
        .select()
        .order('data_hora', ascending: false);

    setState(() {
      localizacoes = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ACOMPANHAR',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
      ),
      body: localizacoes.isEmpty
          ? Center(
              child: Text(
                'Nenhuma localização disponível.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: localizacoes.length,
              itemBuilder: (context, index) {
                final item = localizacoes[index];
                final nomeUsuario = item['user_name'];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                      ),
                      title: Text(
                        '$nomeUsuario',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Data: ${item['data_hora']}\nLat: ${item['latitude']}, Lng: ${item['longitude']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () => GoRouter.of(context)
                          .push('/location-share-map/${item['user_id']}'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  late final StreamSubscription<List<Map<String, dynamic>>> _subscription;

  void _setupRealtime() {
    _subscription = _supabase
        .from('localizacoes')
        .stream(primaryKey: ['id_localizacao'])
        .order('data_hora', ascending: false)
        .listen((List<Map<String, dynamic>> data) {
          if (!mounted) return;

          setState(() {
            localizacoes = data;
          });
        });
  }
}
