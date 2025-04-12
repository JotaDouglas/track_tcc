import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HistoricoView extends StatefulWidget {
  const HistoricoView({super.key});

  @override
  State<HistoricoView> createState() => _HistoricoViewState();
}

class _HistoricoViewState extends State<HistoricoView> {
  @override
  Widget build(BuildContext context) {
    LatLng position = LatLng(-22.325743, -47.37743);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historico"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: position, zoom: 15),
        markers: {
          Marker(
            markerId: MarkerId("local"),
            icon: BitmapDescriptor.defaultMarker,
            position: position
          ),
        },
      ),
    );
  }
}
