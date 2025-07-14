import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:track_tcc_app/viewmodel/tracking.viewmodel.dart';

class HistoricMapFlutter extends StatefulWidget {
  final int IdTrack;
  const HistoricMapFlutter({super.key, required this.IdTrack});

  @override
  State<HistoricMapFlutter> createState() => _HistoricMapFlutterState();
}

class _HistoricMapFlutterState extends State<HistoricMapFlutter> {
  final TrackingViewModel viewModel = TrackingViewModel();

  List<LatLng> route = [];
  bool isReady = false;
  @override
  void initState() {
    super.initState();
    readRoute();
  }

  Future<void> readRoute() async {
    final result = await viewModel.getPontosByRota(widget.IdTrack);

    List<LatLng> listaAuxiliar = result
        .where((place) => place.latitude != null && place.longitude != null)
        .map((place) => LatLng(place.latitude!, place.longitude!))
        .toList();

    route = listaAuxiliar;

    setState(() {
      isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trajeto',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
      ),
      body: isReady
          ? route.isEmpty
              ? Center(
                  child: Text("Erro ao carregar os dados"),
                )
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: route.first,
                    initialZoom: 16,
                    minZoom: 5, // Zoom mínimo permitido
                    maxZoom: 18, // Zoom máximo permitido
                    interactionOptions: InteractionOptions(
                      enableMultiFingerGestureRace: true,
                      pinchZoomThreshold: 1,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.exemplo.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: route,
                          strokeWidth: 4,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: route.first,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_pin,
                              color: Colors.green),
                        ),
                        Marker(
                          point: route.last,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.flag, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
