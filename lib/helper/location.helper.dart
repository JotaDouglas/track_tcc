import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:track_tcc_app/model/place.model.dart';

class Locationhelper {
  Future<PlaceModel?> actuallyPosition() async {
    bool serviceEnabled = false;

    late LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.best));

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        DateTime agora = DateTime.now();

        String dataFormatada = '${agora.day.toString().padLeft(2, '0')}/'
            '${agora.month.toString().padLeft(2, '0')}/'
            '${agora.year} '
            '${agora.hour.toString().padLeft(2, '0')}:'
            '${agora.minute.toString().padLeft(2, '0')}';

        log(placemarks[0].toString());
        Placemark place = placemarks[0];
        return PlaceModel(
          city: place.locality == ''
              ? place.subAdministrativeArea == ''
                  ? "Desconhecido"
                  : place.subAdministrativeArea
              : place.locality,
          country: place.country ?? "Desconhecido",
          latitude: position.latitude,
          longitude: position.longitude,
          adress: place.street,
          dateTime: dataFormatada,
        );
      }
      return null;
    } catch (e) {
      log("Erro getting location: $e");
    }

    return null;
  }

  Future<void> checkGps(context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o GPS está ativado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // GPS desativado, pede para o usuário ativar
      await Geolocator.openLocationSettings();
      return;
    }

    // Verifica permissões
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Permissão necessária'),
          content: const Text(
              'Por favor, ative a permissão de localização nas configurações.'),
          actions: [
            TextButton(
              onPressed: () async {
                permission = await Geolocator.requestPermission();
              },
              child: const Text('Abrir configurações'),
            ),
          ],
        ),
      );

      if (permission == LocationPermission.denied) {
        // Permissão negada
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissão negada permanentemente
      await Geolocator.openAppSettings();
      return;
    }

    // GPS ativo e permissões ok, pode prosseguir
    // Position position = await Geolocator.getCurrentPosition();
  }
}
