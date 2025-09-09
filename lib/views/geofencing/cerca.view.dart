import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/geofence.viewmodel.dart';

class GeofenceMapView extends StatelessWidget {
  const GeofenceMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<GeofenceStore>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Geofence")),
      body: Observer(
        builder: (_) => FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(-22.357, -47.384),
            initialZoom: 13,
            onTap: (tapPosition, latlng) {
              store.adicionarPonto(latlng);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.track_tcc_app',
            ),

            // Polígono
            if (store.pontos.isNotEmpty)
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: store.pontos.toList(),
                    color: Colors.blue.withOpacity(0.3),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),

            // Marcadores
            MarkerLayer(
              markers: List.generate(store.pontos.length, (index) {
                final p = store.pontos[index];
                return Marker(
                  point: p,
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Remover ponto"),
                          content: Text(
                            "Deseja remover o ponto em:\nLat: ${p.latitude}\nLng: ${p.longitude}?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                store.removerPonto(index);
                                Navigator.pop(ctx);
                              },
                              child: const Text("Remover"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
