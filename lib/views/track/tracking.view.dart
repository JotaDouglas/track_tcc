import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:track_tcc_app/helper/location.helper.dart';
import 'package:track_tcc_app/model/place.model.dart';
import 'package:track_tcc_app/viewmodel/tracking.viewmodel.dart';
import 'package:track_tcc_app/views/map.view.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  final Locationhelper _locationHelper = Locationhelper();
  final TrackingViewModel viewModel = TrackingViewModel();
  final MapController _mapController = MapController();

  List<PlaceModel> trackList = [];
  bool isLoading = false;
  Timer? temp;
  bool loopOn = false;
  List<LatLng> listMap = [];

  @override
  void initState() {
    requestLocationPermission();
    super.initState();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;

    if (!status.isGranted) {
      status = await Permission.location.request();
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permissão necessária'),
            content: const Text(
              'Por favor, ative a permissão de localização nas configurações.',
            ),
            actions: [
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Abrir configurações'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> startTrack() async {
    toggleTrackingState();

    if (loopOn) {
      final newLocal = await _locationHelper.actuallyPosition();

      if (newLocal != null) {
        await viewModel.startTracking(newLocal); // Insere a nova rota
        listMap.add(LatLng(newLocal.latitude!, newLocal.longitude!));
        setState(() {
          trackList.insert(0, newLocal);
        });
        getCurrentLocation(); // Começa o loop de rastreamento
      } else {
        toggleTrackingState(); // Cancela se não tiver localização
      }
    } else {
      if (trackList.isNotEmpty) {
        await viewModel.stopTracking(trackList.first); // Finaliza a rota
      }
      stopTracking(); // Cancela o timer
    }
  }

  void toggleTrackingState() {
    setState(() {
      loopOn = !loopOn;
    });
  }

  void stopTracking() {
    temp?.cancel();
    log('Rastreamento finalizado');
  }

  Future<void> getCurrentLocation() async {
    log('Iniciando loop de rastreamento...');

    temp = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        setState(() {
          isLoading = true;
        });

        try {
          final newLocal = await _locationHelper.actuallyPosition();

          if (newLocal != null) {
            await viewModel.trackLocation(newLocal); // Insere ponto no banco
            final pos = LatLng(newLocal.latitude!, newLocal.longitude!);
            listMap.add(pos);

            setState(() {
              trackList.insert(0, newLocal);
            });
            _mapController.move(pos, 16);
          }
        } catch (e) {
          log("Erro ao obter localização: $e");
          stopTracking();
          toggleTrackingState();
        }

        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TRACKING",
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
          Column(
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              trackList.isEmpty
                  ? const Center(child: Text("Nenhum local registrado ainda."))
                  : Expanded(
                      child: TrackingMapWidget(
                        trackList: listMap,
                        mapController: _mapController,
                      ),
                    ),
              const SizedBox(height: 70),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  startTrack();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  loopOn ? 'Parar Rastreamento' : 'Iniciar Rastreamento',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
