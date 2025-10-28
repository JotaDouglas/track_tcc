import 'package:mobx/mobx.dart';
import 'package:latlong2/latlong.dart';

part 'cerca.viewmodel.g.dart';

class CercaViewModel = CercaViewModelBase with _$CercaViewModel;

abstract class CercaViewModelBase with Store {
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
}
