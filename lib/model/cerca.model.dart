import 'package:latlong2/latlong.dart';

class CercaModel {
  String? id;
  String? data;
  List<List<LatLng>>? geofenceList; 

  CercaModel({
    this.id,
    this.data,
    this.geofenceList
  });
}