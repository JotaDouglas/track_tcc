import 'package:flutter/material.dart';
import 'package:track_tcc_app/helper/DateConversion.helper.dart';
import 'package:track_tcc_app/model/place.model.dart';
import 'package:track_tcc_app/viewmodel/tracking.viewmodel.dart';
import 'package:track_tcc_app/views/historicos/historico_map.view.dart';

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

  Future<void> deletarRota(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Rota"),
        content: const Text("Tem certeza que deseja excluir esta rota?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await viewModel.removeRota(id);
      await loadRotas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Rotas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      "🚩 Rota ${index + 1}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.play_arrow, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(DateConversion.convertDateTimeFromString(
                                  rota.dateInicial!)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.stop, color: Colors.red),
                              const SizedBox(width: 4),
                              Text(DateConversion.convertDateTimeFromString(
                                  rota.dateFinal ?? '')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 12,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.map, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HistoricMapFlutter(
                                  IdTrack: rota.id!,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deletarRota(rota.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
