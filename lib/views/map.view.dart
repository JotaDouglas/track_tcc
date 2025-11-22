import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:track_tcc_app/views/widgets/pulseIcon.widget.dart';

class TrackingMapWidget extends StatelessWidget {
  final ValueNotifier<List<LatLng>> trackList;
  final ValueNotifier<LatLng?> currentPosNotifier;
  final MapController mapController;
  final bool modeRoute;

  const TrackingMapWidget({
    super.key,
    required this.trackList,
    required this.mapController,
    required this.currentPosNotifier,
    this.modeRoute = true,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = LatLng(-23.5505, -46.6333);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: fallback,
        initialZoom: 16.0,
      ),
      children: [
        // Mapa base
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.tracktcc.nome',
        ),

        // Marcador (ponto atual)
        ValueListenableBuilder<LatLng?>(
          valueListenable: currentPosNotifier,
          builder: (context, value, _) {
            if (value == null) return const SizedBox.shrink();

            return MarkerLayer(
              markers: [
                Marker(
                  point: value,
                  width: 40,
                  height: 40,
                  child: PulseMarker(),
                ),
              ],
            );
          },
        ),

        // Linha (rota)
        if (modeRoute)
          ValueListenableBuilder<List<LatLng>>(
            valueListenable: trackList,
            builder: (context, points, _) {
              return PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
