import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/helper/location.helper.dart';
import 'package:track_tcc_app/model/place.model.dart';
import 'package:track_tcc_app/viewmodel/amizade.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/tracking.viewmodel.dart';
import 'package:track_tcc_app/views/widgets/alert_message.widget.dart';
import 'package:track_tcc_app/views/widgets/loading.widget.dart';
import 'package:track_tcc_app/views/widgets/quick_message.widget.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  final Locationhelper _locationHelper = Locationhelper();
  final TrackingViewModel viewModel = TrackingViewModel();

  String? nome;

  List<PlaceModel> trackList = [];
  bool isLoading = false;
  Timer? temp;
  bool loopOn = false;
  bool _sharing = false;

  double _distanceMeters = 0.0;
  String _addressLabel = '';
  PlaceModel? _lastPlace;
  LatLng? _lastPosition;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
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

  void popWidget() {
    Navigator.pop(context);
  }

  void toggleTrackingState() {
    if (mounted) {
      setState(() {
        loopOn = !loopOn;
      });
    }
  }

  Future<void> _startSharing() async {
    await WakelockPlus.enable();
    var res;
    if (mounted) {
      res = await Locationhelper().checkGps();
    }
    if (res != true) return;

    //Adicionar trackingLoop do viewmodel
    if (!loopOn) Dialogs.showLoading(context, GlobalKey());
    toggleTrackingState();

    setState(() {
      _sharing = loopOn;
      _distanceMeters = 0.0;
    });

    if (loopOn) {
      final newLocal = await _locationHelper.actuallyPosition();

      if (newLocal != null) {
        if (viewModel.currentRotaId == null) {
          await viewModel.insertTracking(newLocal);
        }

        _lastPlace = newLocal;
        _lastPosition =
            LatLng(newLocal.latitude ?? 0.0, newLocal.longitude ?? 0.0);
        _addressLabel = newLocal.adress ?? 'Endereço não encontrado';

        setState(() {
          trackList.insert(0, newLocal);
        });

        _trackOnce(); // faz a primeira leitura
        _startTimer(); // começa o timer para continuar rastreando
      } else {
        toggleTrackingState();
        setState(() => _sharing = false);
      }

      popWidget(); // fecha o loading
    } else {
      if (trackList.isNotEmpty) {
        await viewModel.stopTracking(trackList.first);
      }

      _stopSharing();
      setState(() {
        trackList.clear();
        _addressLabel = '';
        _lastPlace = null;
        _lastPosition = null;
        _distanceMeters = 0.0;
      });
    }
  }

  void _startTimer() async {
    temp = Timer.periodic(const Duration(seconds: 5), (_) => _trackOnce());
  }

  Future<void> _trackOnce() async {
    try {
      final newLocal = await _locationHelper.actuallyPosition();

      if (newLocal != null) {
        // Calcular distância
        final newLatLng =
            LatLng(newLocal.latitude ?? 0.0, newLocal.longitude ?? 0.0);
        if (_lastPosition != null) {
          _distanceMeters += const Distance().as(
            LengthUnit.Meter,
            _lastPosition!,
            newLatLng,
          );
        }

        _lastPosition = newLatLng;
        _lastPlace = newLocal;
        _addressLabel = newLocal.adress ?? 'Endereço não encontrado';

        await viewModel.trackLocation(newLocal, nome ?? 'Sem nome');

        setState(() {
          trackList.insert(0, newLocal);
        });
      } else {
        log('Localização retornou null.');
      }
    } catch (e) {
      log('Erro no rastreamento: $e');
      _stopSharing();
      toggleTrackingState();
    }
  }

  void _stopSharing() async {
    await WakelockPlus.disable();
    temp?.cancel();
    temp = null;
    log('Rastreamento finalizado');
    if (mounted) {
      setState(() => _sharing = false);
    } else {
      _sharing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<LoginViewModel>(context);
    nome = authViewModel.loginUser?.username ??
        'user${DateTime.now().microsecond}';
    String nomeCompleto = "${authViewModel.loginUser?.username}${authViewModel.loginUser?.sobrenome ?? 'username'}";

    final amizadeVM = Provider.of<AmizadeViewModel>(context);
    amizadeVM.readMyFriends();

    List<String> amigos = [];
    // supondo que amizadeVM.friends seja uma lista de maps
    for (var amigo in amizadeVM.friends) {
      String messageid =
          amigo['remetente']['email'] != authViewModel.loginUser!.email
              ? amigo['remetente']['message_id']
              : amigo['destinatario']['message_id'];

      amigos.add(messageid);
    }

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
      backgroundColor: _sharing ? Colors.black87 : null,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assistant_navigation,
                  size: _sharing ? 100 : 80,
                  color: Colors.orange[900],
                ),
                const SizedBox(height: 24),
                Text(
                  _sharing
                      ? 'Rastreamento em andamento'
                      : 'Toque para iniciar o compartilhamento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange[900],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (_sharing) ...[
                  Text(
                    'Distância: ${_distanceMeters.toStringAsFixed(1)} m',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _addressLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                          ),
                          icon: const Icon(Icons.message, color: Colors.white),
                          label: const FittedBox(
                            // para o texto não estourar
                            child: Text(
                              "Mensagem rápida",
                              style: TextStyle(color: Colors.white),
                              maxLines: 1,
                            ),
                          ),
                          onPressed: () {
                            showQuickMessageBottomSheet(context, amigos, nomeCompleto);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                          ),
                          icon: const Icon(Icons.warning_amber_rounded,
                              color: Colors.white),
                          label: const FittedBox(
                            child: Text(
                              "Situação de Perigo",
                              style: TextStyle(color: Colors.white),
                              maxLines: 1,
                            ),
                          ),
                          onPressed: () {
                            showEmergencyConfirmationDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.orange[900],
                  ),
                  onPressed: _startSharing,
                  child: Text(
                    _sharing ? 'PARAR' : 'INICIAR',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
