import 'package:mobx/mobx.dart';
import 'package:latlong2/latlong.dart';

part 'geofence.viewmodel.g.dart';

class GeofenceStore = _GeofenceStoreBase with _$GeofenceStore;

abstract class _GeofenceStoreBase with Store {
   @observable
  ObservableList<List<LatLng>> quadrados = ObservableList<List<LatLng>>();

  @action
  void adicionarQuadrado(LatLng center, {double delta = 0.001}) {
    final quadrado = [
      LatLng(center.latitude - delta, center.longitude - delta),
      LatLng(center.latitude - delta, center.longitude + delta),
      LatLng(center.latitude + delta, center.longitude + delta),
      LatLng(center.latitude + delta, center.longitude - delta),
    ];
    quadrados.add(quadrado);
  }

  @action
  void limparQuadrados() {
    quadrados.clear();
  }
}
