import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/cerca.viewmodel.dart';

class CercaMapView extends StatefulWidget {
  const CercaMapView({super.key});

  @override
  State<CercaMapView> createState() => _CercaMapViewState();
}

class _CercaMapViewState extends State<CercaMapView> {
  final TextEditingController _nomeController = TextEditingController();
  CercaViewModel cercaVM = CercaViewModel();

  @override
  void initState() {
    super.initState();
    cercaVM = Provider.of<CercaViewModel>(context, listen: false);
    cercaVM.listarCercas();
  }

  @override
  Widget build(BuildContext context) {
    cercaVM = Provider.of<CercaViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Definir Cerca"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (_nomeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Dê um nome à cerca antes de salvar")),
                );
                return;
              }
              await cercaVM.salvarCerca(_nomeController.text);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text("Cerca salva com sucesso!")),
              // );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: cercaVM.limparPontos,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: "Nome da cerca",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) => Observer(
                builder: (_) => FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                        -23.5505, -46.6333), // ponto inicial (SP só de exemplo)
                    initialZoom: 14,
                    onTap: (tapPos, latlng) => cercaVM.adicionarPonto(latlng),
                  ),
                  children: [
                    // seu mapa base
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),

                    // marcadores dos pontos clicados
                    MarkerLayer(
                      markers: cercaVM.pontos
                          .map(
                            (p) => Marker(
                              point: p,
                              width: 30,
                              height: 30,
                              child: const Icon(Icons.location_on,
                                  color: Colors.red),
                            ),
                          )
                          .toList(),
                    ),

                    // polígono da cerca (quando houver pontos)
                    if (cercaVM.pontos.isNotEmpty)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: cercaVM.pontos.toList(),
                            color: Colors.blue.withOpacity(0.3),
                            borderColor: Colors.blue,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (_) => Observer(
              builder: (_) => ListView(
                children: cercaVM.cercasSalvas
                    .map(
                      (nome) => ListTile(
                        title: Text(nome),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await cercaVM.deletarCerca(nome);
                            Navigator.pop(context);
                          },
                        ),
                        onTap: () async {
                          await cercaVM.carregarCerca(nome);
                          _nomeController.text = nome;
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        },
        label: const Text("Cercas salvas"),
        icon: const Icon(Icons.list),
      ),
    );
  }
}
