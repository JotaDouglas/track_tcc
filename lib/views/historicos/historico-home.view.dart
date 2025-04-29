import 'package:flutter/material.dart';
import 'package:track_tcc_app/model/place.model.dart';
import 'package:track_tcc_app/viewmodel/tracking.viewmodel.dart';
import 'package:track_tcc_app/views/historicos/historico-home-detalhes.view.dart';

class RotasPage extends StatefulWidget {
  const RotasPage({super.key});

  @override
  State<RotasPage> createState() => _RotasPageState();
}

class _RotasPageState extends State<RotasPage> {
  final TrackingViewModel viewModel = TrackingViewModel();
  List<PlaceModel> rotas = [];

  @override
  void initState() {
    super.initState();
    loadRotas();
  }

  Future<void> loadRotas() async {
    final result = await viewModel.getAllRotas();
    setState(() {
      rotas = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Rotas'),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
      ),
      body: rotas.isEmpty
          ? const Center(child: Text('Nenhuma rota encontrada.'))
          : ListView.builder(
              itemCount: rotas.length,
              itemBuilder: (context, index) {
                final rota = rotas[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(rota.titulo ?? 'Rota sem título'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Início: ${rota.latitude}, ${rota.longitude}'),
                        // Text('Fim: ${rota.la}, ${rota.longFinal}'),
                        Text('Data: ${rota.dateTime}'),
                        Text('Distância: ${rota.id ?? '--'} km'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RotaDetalhePage(rotaId: rota.id!),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
