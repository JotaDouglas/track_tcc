import 'dart:developer';

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
          locationSettings: LocationSettings(accuracy: LocationAccuracy.best));

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
          city: place.locality == '' ? place.subAdministrativeArea == '' ? "Desconhecido" : place.subAdministrativeArea: place.locality,
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
}
