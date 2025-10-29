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

  @observable
  ObservableMap<String, List<LatLng>> cercasMap =
      ObservableMap<String, List<LatLng>>();

  @observable
  String? cercaAtual;

  @observable
  String modo = 'visualizar'; // 'criar', 'editar', 'visualizar'

  @action
  void adicionarPonto(LatLng ponto) => pontos.add(ponto);

  @action
  void removerPonto(int index) {
    if (index >= 0 && index < pontos.length) {
      pontos.removeAt(index);
    }
  }

  @action
  void limparPontos() => pontos.clear();

  @action
  Future<void> salvarCerca(String nome) async {
    await _cercaRepository.salvarCerca(nome, pontos.toList());
    cercaAtual = nome;
    await listarCercas();
  }

  @action
  Future<void> carregarCerca(String nome) async {
    final carregados = await _cercaRepository.carregarCerca(nome);
    if (carregados != null) {
      cercaAtual = nome;
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
    if (cercaAtual == nome) {
      limparPontos();
      cercaAtual = null;
    }
    await listarCercas();
  }

  @action
  void iniciarNovaCerca() {
    limparPontos();
    cercaAtual = null;
    modo = 'criar';
  }

  @action
  Future<void> editarCerca(String nome) async {
    await carregarCerca(nome);
    modo = 'editar';
  }

  @action
  void finalizarEdicao() {
    modo = 'visualizar';
  }

  @action
  Future<void> carregarTodasCercas() async {
    cercasMap.clear();
    for (var nome in cercasSalvas) {
      final carregados = await _cercaRepository.carregarCerca(nome);
      if (carregados != null) {
        cercasMap[nome] = carregados;
      }
    }
  }
}
