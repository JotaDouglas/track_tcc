import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:track_tcc_app/views/map.view.dart';

class LiveTrackingPage extends StatefulWidget {
  final String? userId;

  const LiveTrackingPage({super.key, this.userId});

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final MapController _mapController = MapController();
  final List<LatLng> _path = [];

  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenRealtime();
  }

  void _listenRealtime() {
    final stream =
        supabase.from('localizacoes').stream(primaryKey: ['id_localizacao']);

    _sub = stream.listen((rows) {
      final filteredRows =
          rows.where((row) => row['user_id'] == "c8dbca7e-c188-4ce8-90d2-518284763a76").toList();

      if (filteredRows.isEmpty) return;

      // Use filteredRows[0] ou como preferir
    });

    _sub = stream.listen((rows) {
      // Filtra no Dart, porque filtro direto não existe
      final filteredRows = (widget.userId == null)
          ? rows
          : rows.where((row) => row['user_id'] == widget.userId).toList();

      if (filteredRows.isEmpty) return;

      final newPath = filteredRows.map((row) {
        final lat = (row['latitude'] as num).toDouble();
        final lon = (row['longitude'] as num).toDouble();
        return LatLng(lat, lon);
      }).toList();

      final latestPoint = newPath.last;

      setState(() {
        _path
          ..clear();
          // ..addAll(newPath);
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(latestPoint, 16.0);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastreamento em Tempo Real'),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          TrackingMapWidget(
            trackList: _path,
            mapController: _mapController,
            modeRoute: false,
          ),
          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 3),
            ),
        ],
      ),
    );
  }
}
