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
            initialCenter: LatLng(-23.5505, -46.6333),
            initialZoom: 13,
            onTap: (tapPos, latlng) {
              store.adicionarQuadrado(latlng);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.track_tcc_app',
            ),

            // Quadrados
            if (store.quadrados.isNotEmpty)
              PolygonLayer(
                polygons: store.quadrados
                    .map((q) => Polygon(
                          points: q,
                          color: Colors.blue.withOpacity(0.3),
                          borderColor: Colors.blue,
                          borderStrokeWidth: 2,
                        ))
                    .toList(),
              ),

            // Linhas ligando os centros
            if (store.quadrados.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: store.quadrados.map((q) {
                      final lat =
                          q.map((p) => p.latitude).reduce((a, b) => a + b) /
                              q.length;
                      final lng =
                          q.map((p) => p.longitude).reduce((a, b) => a + b) /
                              q.length;
                      return LatLng(lat, lng);
                    }).toList(),
                    color: Colors.red,
                    strokeWidth: 3,
                  ),
                ],
              ),

            // Marcadores centrais invisíveis para excluir
            MarkerLayer(
              markers: List.generate(store.quadrados.length, (index) {
                final q = store.quadrados[index];
                final lat =
                    q.map((p) => p.latitude).reduce((a, b) => a + b) / q.length;
                final lng = q.map((p) => p.longitude).reduce((a, b) => a + b) /
                    q.length;

                return Marker(
                  point: LatLng(lat, lng),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Remover quadrado"),
                          content: Text("Deseja remover este quadrado?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                store.removerQuadrado(index);
                                Navigator.pop(ctx);
                              },
                              child: const Text("Remover"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.square_foot,
                      color: Colors.transparent, // marcador invisível
                      size: 40,
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
