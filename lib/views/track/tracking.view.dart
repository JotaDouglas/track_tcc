import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:track_tcc_app/helper/location.helper.dart';

import 'package:track_tcc_app/model/place.model.dart';

import 'package:track_tcc_app/viewmodel/tracking.viewmodel.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({Key? key}) : super(key: key);

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage>
    with SingleTickerProviderStateMixin {
  final Locationhelper _locationHelper = Locationhelper();
  final TrackingViewModel _viewModel = TrackingViewModel();

  Timer? _timer;
  bool _sharing = false;
  double _distanceMeters = 0.0;
  Position? _lastPosition;
  PlaceModel? _lastPlace;
  String _addressLabel = '';

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.8,
      upperBound: 1.2,
    )
      ..addListener(() => setState(() {}))
      ..repeat(reverse: true);
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) await Geolocator.openLocationSettings();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }
  }

  void _startSharing() async {
    await WakelockPlus.enable();
    setState(() {
      _sharing = true;
      _distanceMeters = 0.0;
    });
    _lastPosition = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.best));
    _lastPlace = await _locationHelper.actuallyPosition();
    _addressLabel = _lastPlace?.adress ?? '';
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      Position pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.best));
      final newPlace = await _locationHelper.actuallyPosition();
      if (_lastPosition != null) {
        _distanceMeters += Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          pos.latitude,
          pos.longitude,
        );
      }
      _lastPosition = pos;
      if (newPlace != null) {
        _lastPlace = newPlace;
        _addressLabel = newPlace.city ?? '';
        await _viewModel.trackLocation(newPlace, newPlace.city ?? '');
      }
      setState(() {});
    });
  }

  void _stopSharing() async {
    _timer?.cancel();
    await WakelockPlus.disable();
    setState(() {
      _sharing = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compartilhamento'),
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
      ),
      backgroundColor: _sharing ? Colors.black54 : null,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                  visible: !_sharing,
                  child: Icon(Icons.assistant_navigation,
                      size: 100, color: Colors.orange[900]),
                ),
                Visibility(
                  visible: _sharing,
                  child: Transform.scale(
                    scale: _pulseController.value,
                    child: Icon(Icons.assistant_navigation,
                        size: 100, color: _sharing ? Colors.orange[900] : null),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _sharing
                            ? 'Meu endereço atual: $_addressLabel'
                            : 'Comece um novo compartilhamento',
                        style: TextStyle(color: _sharing ? Colors.white: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_sharing) ...[
                  Text(
                    'Distância: ${_distanceMeters.toStringAsFixed(1)} m',
                    style: TextStyle(color: _sharing ? Colors.white: Colors.black),
                    // style: theme.textTheme.subtitle1,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.message),
                        color: _sharing ? Colors.orange[900] : null,
                        iconSize: 32,
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_active),
                        color: _sharing ? Colors.orange[900]: null,
                        iconSize: 32,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor:  Colors.orange[900],
                  ),
                  onPressed: _sharing ? _stopSharing : _startSharing,
                  child: Text(
                    _sharing
                        ? 'PARAR'
                        : 'INICIAR',
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
