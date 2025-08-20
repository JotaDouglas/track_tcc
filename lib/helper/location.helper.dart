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
          dateInicial: dataFormatada,
        );
      }
      return null;
    } catch (e) {
      log("Erro getting location: $e");
    }

    return null;
  }

  Future checkGps(context) async {
    // 1. Verifica se GPS está ativado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Mostra diálogo e abre configurações para ativar GPS
      bool gpsEnabledByUser = false;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('GPS desativado'),
          content: const Text(
              'Por favor, ative o GPS para continuar usando o aplicativo.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
                // Aqui, não tem retorno direto se o usuário ativou ou não o GPS
                // Pode fazer uma espera ou checar novamente ao voltar
              },
              child: const Text('Abrir configurações'),
            ),
          ],
        ),
      );

      // Após o diálogo, espera um tempo e verifica novamente se o GPS foi ativado
      await Future.delayed(const Duration(seconds: 2));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        // Se ainda não ativou, retorna false para indicar que não pode prosseguir
        return false;
      }
    }

    // 2. Verifica permissão de localização
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissão negada pelo usuário
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissão negada permanentemente, abre configurações do app
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permissão negada'),
          content: const Text(
              'A permissão de localização foi negada permanentemente. Por favor, ative nas configurações do dispositivo.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
              child: const Text('Abrir configurações'),
            ),
          ],
        ),
      );
      return false;
    }

    // Tudo ok: GPS ativo e permissão concedida
    return true;

    // GPS ativo e permissões ok, pode prosseguir
    // Position position = await Geolocator.getCurrentPosition();
  }
}
