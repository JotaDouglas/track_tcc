import 'package:mobx/mobx.dart';
import 'package:latlong2/latlong.dart';

part 'geofence.viewmodel.g.dart';

class GeofenceStore = _GeofenceStoreBase with _$GeofenceStore;

abstract class _GeofenceStoreBase with Store {
  @observable
  ObservableList<LatLng> pontos = ObservableList<LatLng>();

  @action
  void adicionarPonto(LatLng ponto) {
    pontos.add(ponto);
  }

  @action
  void limparPontos() {
    pontos.clear();
  }

  @action
  void removerPonto(int index) {
    if (index >= 0 && index < pontos.length) {
      pontos.removeAt(index);
    }
  }
}
