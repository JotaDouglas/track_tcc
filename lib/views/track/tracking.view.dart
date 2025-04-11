import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:track_tcc_app/helper/location.helper.dart';
import 'package:track_tcc_app/model/place.model.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  final Locationhelper _locationHelper = Locationhelper();
  List<PlaceModel> trackList = [];
  bool isLoading = false;
  Timer? temp;
  bool loopOn = false;

  Future startTrack() async {
    toggleLoading();

    if (loopOn) {
      getCurrentLocation();
    } else {
      stopTracking();
    }
  }

  void toggleLoading() {
    setState(() {
      loopOn = !loopOn;
    });
  }

  void stopTracking() {
    temp?.cancel();
    log('rastreamento finalizado');
  }

  Future getCurrentLocation() async {
    log('Start Track');

    temp = Timer.periodic(
      const Duration(seconds: 20),
      (timer) async {
        setState(() {
          isLoading = true;
        });

        try {
          final newLocal = await _locationHelper.actuallyPosition();

          setState(() {
            trackList.insert(
                0, newLocal!); // Insere o novo local no topo da lista
          });
        } catch (e) {
          log("erro ao obter localização: $e");
          stopTracking();
          toggleLoading();
        }

        Future.delayed(const Duration(seconds: 1)).then(
          (_) => setState(() {
            isLoading = false;
          }),
        );
      },
    );
  }

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
      // Exibe alerta ou redireciona o usuário para configurações
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permissão necessária'),
            content: const Text(
                'Por favor, ative a permissão de localização nas configurações.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("TRACK"),
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: trackList.isEmpty
                ? const Center(child: Text("Nenhum local registrado ainda."))
                : ListView.builder(
                    reverse: false,
                    itemCount: trackList.length,
                    itemBuilder: (context, index) {
                      final local = trackList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(local.adress ?? 'Endereço desconhecido'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Cidade: ${local.city ?? '--'}"),
                              Text("País: ${local.country ?? '--'}"),
                              Text(
                                  "Latitude: ${local.latitude?.toStringAsFixed(6)}"),
                              Text(
                                  "Longitude: ${local.longitude?.toStringAsFixed(6)}"),
                              Text("Data: ${local.dateTime.toString()}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          startTrack();
        },
        backgroundColor: Colors.green[900],
        child: Icon(
          loopOn ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }
}
