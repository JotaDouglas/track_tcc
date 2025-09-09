import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:latlong2/latlong.dart';
import 'package:track_tcc_app/viewmodel/geofence.viewmodel.dart';


class GeofenceMapView extends StatelessWidget {
  final GeofenceStore store;

  const GeofenceMapView({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-23.5505, -46.6333), // São Paulo só de exemplo
          initialZoom: 13,
          onTap: (tapPosition, latlng) {
            store.adicionarPonto(latlng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
            additionalOptions: {
              'accessToken': 'SEU_TOKEN_MAPBOX',
              'id': 'mapbox/streets-v11',
            },
          ),

          // Pontos marcados
          MarkerLayer(
            markers: store.pontos.map((p) => Marker(
              point: p,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, color: Colors.red),
            )).toList(),
          ),

          // Polígono da cerca
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
        ],
      ),
    );
  }
}
