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
                      rota.titulo ?? 'Rota sem título',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text('Início: ${rota.latitude}, ${rota.longitude}'),
                          // Text('Fim: ${rota.la}, ${rota.longFinal}'),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    color: Colors.green,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            ' ${DateConversion.convertDateTimeFromString(rota.dateInicial!)}'),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.stop,
                                    color: Colors.red,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            ' ${DateConversion.convertDateTimeFromString(rota.dateFinal ?? '')}'),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                    onTap: () {
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
                );
              },
            ),
    );
  }
}
