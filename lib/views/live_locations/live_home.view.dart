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
        .select('*, usuarios(nome)')
        .order('data_hora', ascending: false);

    setState(() {
      localizacoes = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Localizações em tempo real')),
      body: ListView.builder(
        itemCount: localizacoes.length,
        itemBuilder: (context, index) {
          final item = localizacoes[index];
          final usuario = item['usuarios'];
          final nomeUsuario =
              usuario != null ? usuario['nome'] : 'Usuário desconhecido';

          return Card(
            child: ListTile(
              leading: Icon(Icons.location_on),
              title: Text('$nomeUsuario'),
              subtitle: Text(
                'Data: ${item['data_hora']}\n Lat: ${item['latitude']}, Lng: ${item['longitude']}',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () => GoRouter.of(context).push('/location-share-map/${item['user_id']}'),
            ),
          );
        },
      ),
    );
  }

  void _setupRealtime() {
    _supabase
        .from('localizacoes')
        .stream(primaryKey: ['id_localizacao'])
        .order('data_hora', ascending: false)
        .listen(
          (List<Map<String, dynamic>> data) {
            setState(
              () {
                localizacoes = data;
              },
            );
          },
        );
  }
}
