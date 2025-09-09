import 'package:mobx/mobx.dart';
import 'package:latlong2/latlong.dart';
import 'package:track_tcc_app/model/cerca.model.dart';


// <- onde você colocar a classe Geofence

part 'geofence.viewmodel.g.dart';

class GeofenceStore = _GeofenceStoreBase with _$GeofenceStore;

abstract class _GeofenceStoreBase with Store {
  @observable
  ObservableList<List<LatLng>> quadrados = ObservableList<List<LatLng>>();

  @observable
  ObservableList<CercaModel> cercas = ObservableList<CercaModel>();

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
  void removerQuadrado(int index) {
    if (index >= 0 && index < quadrados.length) {
      quadrados.removeAt(index);
    }
  }

  @action
  void limparQuadrados() {
    quadrados.clear();
  }

  @action
  void salvarCerca(String nome) {
    if (quadrados.isEmpty) return;
    final novaCerca = CercaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: nome,
      geofenceList: List.from(quadrados), // copia
    );
    cercas.add(novaCerca);
    quadrados.clear(); // limpa a cerca temporária
  }
}

