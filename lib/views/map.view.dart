import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:track_tcc_app/views/widgets/pulseIcon.widget.dart';

class TrackingMapWidget extends StatefulWidget {
  final List<LatLng> trackList;
  final MapController mapController;

  const TrackingMapWidget({
    super.key,
    required this.trackList,
    required this.mapController,
  });

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  @override
  Widget build(BuildContext context) {
    final currentPos = widget.trackList.isNotEmpty
        ? widget.trackList.last
        : LatLng(-23.5505, -46.6333); // fallback padrão
    print(currentPos);

    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: currentPos, // <-- Isso é pra versão nova (v7+)
        initialZoom: 40.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: currentPos,
              width: 40,
              height: 40,
              child: PulseMarker(),
            ),
          ],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: widget.trackList,
              strokeWidth: 4.0,
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }
}
