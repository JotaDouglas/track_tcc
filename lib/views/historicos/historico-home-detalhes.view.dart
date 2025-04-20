import 'package:flutter/material.dart';
import 'package:track_tcc_app/model/place.model.dart';
import 'package:track_tcc_app/viewmodel/tracking.viewmodel.dart';

class RotaDetalhePage extends StatefulWidget {
  final int? rotaId;
  const RotaDetalhePage({super.key, required this.rotaId});

  @override
  State<RotaDetalhePage> createState() => _RotaDetalhePageState();
}

class _RotaDetalhePageState extends State<RotaDetalhePage> {
  final TrackingViewModel viewModel = TrackingViewModel();
  List<PlaceModel> pontos = [];

  @override
  void initState() {
    super.initState();
    loadPontos();
  }

  Future<void> loadPontos() async {
    final result = await viewModel.getPontosByRota(widget.rotaId!);
    setState(() {
      pontos = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Rota'),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
      ),
      body: pontos.isEmpty
          ? const Center(child: Text('Nenhum ponto registrado nessa rota.'))
          : ListView.builder(
              itemCount: pontos.length,
              itemBuilder: (context, index) {
                final p = pontos[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Lat: ${p.latitude?.toStringAsFixed(6)}'),
                    subtitle: Text(
                        'Lon: ${p.longitude?.toStringAsFixed(6)}\nData: ${p.dateTime}'),
                  ),
                );
              },
            ),
    );
  }
}
