import 'package:mobx/mobx.dart';
import 'package:latlong2/latlong.dart';
import 'package:track_tcc_app/repository/cerca.repository.dart';

part 'cerca.viewmodel.g.dart';

class CercaViewModel = CercaViewModelBase with _$CercaViewModel;

abstract class CercaViewModelBase with Store {
  final CercaRepository _cercaRepository = CercaRepository();

  @observable
  ObservableList<LatLng> pontos = ObservableList<LatLng>();

  @observable
  ObservableList<String> cercasSalvas = ObservableList<String>();

  @action
  void adicionarPonto(LatLng ponto) => pontos.add(ponto);

  @action
  void limparPontos() => pontos.clear();

  @action
  Future<void> salvarCerca(String nome) async {
    await _cercaRepository.salvarCerca(nome, pontos.toList());
    await listarCercas();
  }

  @action
  Future<void> carregarCerca(String nome) async {
    final carregados = await _cercaRepository.carregarCerca(nome);
    if (carregados != null) {
      pontos
        ..clear()
        ..addAll(carregados);
    }
  }

  @action
  Future<void> listarCercas() async {
    final lista = await _cercaRepository.listarCercas();
    cercasSalvas
      ..clear()
      ..addAll(lista);
  }

  @action
  Future<void> deletarCerca(String nome) async {
    await _cercaRepository.deletarCerca(nome);
    await listarCercas();
  }
}
