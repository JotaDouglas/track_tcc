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
  final ValueNotifier<List<LatLng>> _path = ValueNotifier([]);
  final ValueNotifier<LatLng?> _currentPos = ValueNotifier(null);

  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenRealtime();
  }

  void _listenRealtime() {
  if (!mounted || _sub != null) return;

  final stream = supabase
      .from('localizacoes')
      .stream(primaryKey: ['id_localizacao']);

  _sub = stream.listen((rows) {
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

    // Atualiza os Notifiers diretamente
    _path.value = newPath;
    _currentPos.value = latestPoint;

    // Move o mapa suavemente até a nova posição
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(latestPoint, 16.0);
    });
  });
}


  @override
void dispose() {
  _sub?.cancel();
  _path.dispose();
  _currentPos.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tempo Real',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          TrackingMapWidget(
            trackList: _path,
            mapController: _mapController,
            currentPosNotifier: _currentPos,
            modeRoute: true,
          ),
        ],
      ),
    );
  }
}
