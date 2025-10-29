import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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
  late CercaViewModel cercaVM;
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    cercaVM = Provider.of<CercaViewModel>(context, listen: false);
    cercaVM.listarCercas();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço de localização está desabilitado')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada')),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      final latlng = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _currentLocation = latlng;
      });

      // Move o mapa para a posição atual com zoom confortável
      try {
        _mapController.move(latlng, 16);
      } catch (_) {
        // caso o controller ainda não esteja pronto, ignorar
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CercaViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (_) => Text(
            vm.cercaAtual != null
                ? "Editando cerca: ${vm.cercaAtual}"
                : "Nova Cerca",
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (_nomeController.text.isEmpty) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Dê um nome à cerca antes de salvar")),
                );
                return;
              }

              await vm.salvarCerca(_nomeController.text);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Cerca salva com sucesso!")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              if (vm.cercaAtual != null) {
                await vm.deletarCerca(vm.cercaAtual!);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cerca excluída")),
                );
              } else {
                vm.limparPontos();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de modo atual
          Observer(
            builder: (_) => Container(
              color: switch (vm.modo) {
                'editar' => Colors.blue.withOpacity(0.1),
                'visualizar' => Colors.green.withOpacity(0.1),
                _ => Colors.orange.withOpacity(0.1),
              },
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Text(
                "Modo: ${vm.modo.toUpperCase()}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
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
              builder: (_) => FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLocation ?? LatLng(-23.5505, -46.6333),
                  initialZoom: 14,
                  onTap: (tapPos, latlng) {
                    if (vm.modo == 'visualizar') return;
                    vm.adicionarPonto(latlng);
                  },
                  onLongPress: (tapPos, latlng) {
                    final index = _pontoMaisProximo(vm.pontos, latlng);
                    if (index != null) vm.removerPonto(index);
                  },
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom |
                        InteractiveFlag.drag |
                        InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  if (_currentLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: vm.pontos.map((p) {
                      return Marker(
                        point: p,
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            if (vm.modo == 'editar') {
                              final index = _pontoMaisProximo(vm.pontos, p);
                              if (index != null) {
                                vm.removerPonto(index);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Ponto removido")),
                                );
                              }
                            }
                          },
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 32,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (vm.pontos.isNotEmpty)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: [...vm.pontos, vm.pontos.first],
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
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Observer(
        builder: (_) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              heroTag: "nova",
              icon: const Icon(Icons.add_location_alt),
              label: const Text("Nova"),
              onPressed: vm.iniciarNovaCerca,
            ),
            const SizedBox(width: 12),
            FloatingActionButton.extended(
              heroTag: "listar",
              icon: const Icon(Icons.list),
              label: const Text("Cercas"),
              onPressed: () async {
                await vm.listarCercas();
                if (!mounted) return;
                _mostrarCercas(context, vm);
              },
            ),
          ],
        ),
      ),
    );
  }

  int? _pontoMaisProximo(List<LatLng> pontos, LatLng pos) {
    if (pontos.isEmpty) return null;
    double minDist = double.infinity;
    int? minIndex;

    for (int i = 0; i < pontos.length; i++) {
      final d = Distance().as(LengthUnit.Meter, pontos[i], pos);
      if (d < minDist && d < 20) {
        minDist = d;
        minIndex = i;
      }
    }
    return minIndex;
  }

  void _mostrarCercas(BuildContext context, CercaViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Observer(
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Minhas Cercas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: vm.cercasSalvas.length,
                  itemBuilder: (_, i) {
                    final nome = vm.cercasSalvas[i];
                    return ListTile(
                      title: Text(nome),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await vm.carregarCerca(nome);
                              vm.modo = 'editar';
                              _nomeController.text = nome;
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await vm.deletarCerca(nome);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Cerca "$nome" deletada')),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () async {
                        await vm.carregarCerca(nome);
                        vm.modo = 'visualizar';
                        _nomeController.text = nome;
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Cerca "$nome" carregada')),
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Nova Cerca'),
                  onPressed: () {
                    vm.iniciarNovaCerca();
                    _nomeController.clear();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Modo de criação iniciado')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
