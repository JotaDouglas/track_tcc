import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:latlong2/latlong.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/helper/location.helper.dart';
import 'package:track_tcc_app/model/grupo/grupo.model.dart';
import 'package:track_tcc_app/model/place.model.dart';
import 'package:track_tcc_app/repository/track.repository.dart';
import 'package:track_tcc_app/services/background_location_service.dart';
import 'package:track_tcc_app/viewmodel/cerca.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

part 'tracking.viewmodel.g.dart';

class TrackingViewModel = TrackingViewModelBase with _$TrackingViewModel;

abstract class TrackingViewModelBase with Store {
  final TrackRepository trackRepository = TrackRepository();
  final SupabaseClient _supabase = Supabase.instance.client;
  final Locationhelper _locationHelper = Locationhelper();
  final LoginViewModel authViewModel = LoginViewModel();
  final CercaViewModel cercaViewModel = CercaViewModel();

  int? currentRotaId;
  bool _isTracking = false;

  @observable
  ObservableList<PlaceModel> trackList = ObservableList<PlaceModel>();

  @observable
  List<PlaceModel> listRotasOnline = [];

  @observable
  List<PlaceModel> listRotasLocal = [];

  @observable
  bool loading = false;

  @observable
  bool trackingLoop = false;

  @observable
  bool trackingMode = false;

  @observable
  double distanceMeters = 0.0;

  @observable
  PlaceModel? lastPlace;

  @observable
  LatLng? lastPosition;

  @observable
  String addressLabel = '';

  @observable
  List<PlaceModel> trackListLoop = [];

  @observable
  Timer? temp;

  @observable
  int trackingInterval = 30; // Intervalo padrão em segundos

  @observable
  String? cercaSelecionada;

  @observable
  Group? grupoSelecionado;

  @action
  setTrackingInterval(int seconds) async {
    trackingInterval = seconds;

    // Atualizar o intervalo no SharedPreferences para o background service
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tracking_interval', seconds);
    return 1;
  }

  @action
  void changeDistance(double value, {bool reset = false}) {
    if (reset) {
      distanceMeters = 0.0;
    } else {
      distanceMeters += value;
    }
  }

  @action
  void changeLoading(bool value) => loading = value;

  @action
  void toggleTrackingState() {
    trackingLoop = !trackingLoop;
  }

  // Inicia uma nova rota de rastreamento
  @action
  Future<void> insertTracking(PlaceModel initialLocation) async {
    try {
      final rotaId = await trackRepository.insertRota(initialLocation);
      currentRotaId = rotaId;
      trackList.clear();
      trackList.insert(0, initialLocation);
      log('Rota iniciada com ID: $rotaId');
    } catch (e) {
      log('Erro ao iniciar rota: $e');
    }
  }

  // Adiciona uma localização à rota atual
  @action
  Future<void> trackLocation(PlaceModel location, String name) async {
    if (currentRotaId == null) {
      log('Erro: currentRotaId é nulo. Não foi iniciado insertTracking?');
      return;
    }

    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      log('Usuário não autenticado');
      return;
    }

    // Salva localmente primeiro (SQLite)
    await _saveLocationLocally(location);

    // Tenta enviar para Supabase (sem travar o app)
    await _syncLocationToSupabase(location, name, uid);
  }

  // Finaliza o rastreamento da rota atual
  @action
  Future<void> stopTracking(PlaceModel finalLocation) async {
    if (currentRotaId == null) {
      log('Rastreamento já estava parado.');
      return;
    }

    try {
      await trackRepository.updateRotaFinal(currentRotaId!, finalLocation);

      // Remove localização do Supabase
      final uid = _supabase.auth.currentUser?.id;
      if (uid != null) {
        await _supabase.from('localizacoes').delete().eq("user_id", uid);
        log('Localização final removida do Supabase');
      }

      // Sincroniza rota online após finalizar
      await _autoSyncCurrentRoute();

      currentRotaId = null;
    } catch (e) {
      log("Erro ao parar rastreamento: $e");
    }
  }

  // Remove uma rota do banco local
  @action
  Future<void> removeRota(int rotaId) async {
    await trackRepository.deleteRota(rotaId);
  }

  // Carrega todas as rotas salvas localmente
  Future<void> getAllRotas() async {
    final rotasAux = await trackRepository.getAllRotas();
    listRotasLocal = List.from(rotasAux);
  }

  // Carrega rotas sincronizadas online
  @action
  Future<void> getRotasOnline() async {
    changeLoading(true);

    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return;

      final rotasOnline = await trackRepository.getRotasOnline(uid);

      listRotasOnline = _convertToPlaceModelList(rotasOnline);

      if (listRotasOnline.isNotEmpty) {
        listRotasOnline.sort((a, b) => b.id!.compareTo(a.id!));
      }
    } catch (e) {
      log("Erro ao carregar rotas online: $e");
    } finally {
      changeLoading(false);
    }
  }

  // Retorna os pontos de uma rota específica
  Future<List<PlaceModel>> getPontosByRota(int rotaId) async {
    return await trackRepository.getPontosByRotaId(rotaId);
  }

  // Converte string JSON de coordenadas em lista de PlaceModel
  Future<List<PlaceModel>> readCordenadas(String cordenadas) async {
    if (cordenadas.isEmpty) return [];

    try {
      final decoded = jsonDecode(cordenadas);
      final posicoes = decoded[0]['pontos'];

      return posicoes.map<PlaceModel>((p) {
        return PlaceModel(
          id: p['id'],
          latitude: p['latitude'],
          longitude: p['longitude'],
          dateInicial: p['data'],
        );
      }).toList();
    } catch (e) {
      log("Erro ao converter as coordenadas: $e");
      return [];
    }
  }

  // Sincroniza uma rota local com o Supabase
  @action
  Future<bool> syncRota(PlaceModel rota) async {
    try {
      if (rota.id == null || rota.idSistema != null) return false;

      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return false;

      final trajetoJson =
          await trackRepository.gerarJsonRotasComPontos(rota.id!);

      final dados = {
        "user_id": uid,
        "data_inicio": rota.dateInicial,
        "data_fim": rota.dateFinal ?? DateTime.now().toString(),
        "cordenadas": trajetoJson,
      };

      final sucesso = await trackRepository.syncRotas(dados, rota.id!);

      if (sucesso) {
        await removeRota(rota.id ?? -1);
        await getAllRotas();
        await getRotasOnline();
      }

      return sucesso;
    } catch (e) {
      log("Erro ao sincronizar rota: $e");
      return false;
    }
  }

  // Deleta uma rota online
  Future<void> deleteRotaOnline(String id) async {
    changeLoading(true);

    try {
      await trackRepository.deleteRotaOnline(id);
      await getRotasOnline();
    } catch (e) {
      log("Erro ao deletar rota online: $e");
    } finally {
      changeLoading(false);
    }
  }

  // Inicia ou para o rastreamento em tempo real
  @action
  Future<void> startTracking(String userName) async {
    final gpsOn = await _locationHelper.checkGps(null);
    if (gpsOn != true) return;

    toggleTrackingState();
    trackingMode = trackingLoop;
    changeDistance(0, reset: true);

    if (trackingLoop) {
      await _iniciarRastreamento(userName);
    } else {
      await _pararRastreamento();
    }
  }

  // Inicia o loop de rastreamento contínuo
  @action
  Future<void> _startTrackingLoop(String userName) async {
    if (_isTracking) return;
    _isTracking = true;

    log('Iniciando rastreamento com intervalo de $trackingInterval segundos');

    while (_isTracking) {
      final start = DateTime.now();

      try {
        final newLocal = await _locationHelper.actuallyPosition();

        if (newLocal != null) {
          await _processNewLocation(newLocal, userName);
        } else {
          log('Localização retornou null.');
        }
      } catch (e, stack) {
        log('Erro no rastreamento: $e\n$stack');
      }

      // Aguarda o intervalo configurado
      final elapsed = DateTime.now().difference(start);
      final waitTime = Duration(seconds: trackingInterval) - elapsed;

      if (waitTime.isNegative) {
        log('Envio demorou mais que o intervalo, iniciando novo ciclo');
        continue;
      }

      await Future.delayed(waitTime);
    }

    log('Rastreamento encerrado');
  }

  // Para o loop de rastreamento
  void stopTrackingLoop() {
    _isTracking = false;
    log('Solicitada parada do rastreamento');
  }

  // Realiza um único rastreamento
  @action
  Future<void> _trackOnce(String userName) async {
    try {
      final newLocal = await _locationHelper.actuallyPosition();

      if (newLocal != null) {
        await _processNewLocation(newLocal, userName);
      } else {
        log('Localização retornou null.');
      }
    } catch (e) {
      log('Erro no rastreamento: $e');
      _stopSharing();
      toggleTrackingState();
    }
  }

  // Método auxiliar usado para compatibilidade
  Future<void> primeiroTrack() async {
    final userName = authViewModel.loginUser?.username ?? 'Sem nome';
    await _trackOnce(userName);
  }

  // Valida se o ponto está dentro de alguma cerca do grupo
  Future<void> validarDentroDeAlgumaCerca(LatLng ponto) async {
    final grupo = grupoSelecionado;

    if (grupo == null) {
      log("Nenhum grupo selecionado.");
      return;
    }

    if (grupo.cercasPoligonos.isEmpty) {
      log("Grupo selecionado não possui cercas.");
      return;
    }

    for (var cerca in grupo.cercasPoligonos) {
      if (pontoDentroDaCerca(ponto, cerca.pontos)) {
        log('DENTRO de uma cerca do grupo: ${cerca.nome}');
        return;
      }
    }

    log('FORA de todas as cercas do grupo: ${grupo.nome}');
  }

  // Algoritmo Ray Casting para verificar se ponto está dentro do polígono
  bool pontoDentroDaCerca(LatLng ponto, List<LatLng> poligono) {
    int intersectCount = 0;

    for (int j = 0; j < poligono.length; j++) {
      final a = poligono[j];
      final b = poligono[(j + 1) % poligono.length];

      if (((a.latitude > ponto.latitude) != (b.latitude > ponto.latitude)) &&
          (ponto.longitude <
              (b.longitude - a.longitude) *
                      (ponto.latitude - a.latitude) /
                      (b.latitude - a.latitude) +
                  a.longitude)) {
        intersectCount++;
      }
    }

    return (intersectCount % 2) == 1;
  }

  // Salva localização localmente no SQLite
  Future<void> _saveLocationLocally(PlaceModel location) async {
    try {
      trackList.insert(0, location);
      await trackRepository.insertRotaPoint(currentRotaId!, location);
      log('Localização salva no SQLite: ${location.latitude}, ${location.longitude}');
    } catch (e, stack) {
      log('Erro ao salvar localmente: $e\n$stack');
    }
  }

  // Sincroniza localização com Supabase
  Future<void> _syncLocationToSupabase(
    PlaceModel location,
    String name,
    String uid,
  ) async {
    try {
      final row = {
        'user_id': uid,
        'data_hora': DateTime.now().toIso8601String(),
        'latitude': location.latitude,
        'longitude': location.longitude,
        'user_name': name,
      };

      await _supabase.from('localizacoes').upsert(row, onConflict: 'user_id');
      log('Localização enviada para Supabase: $row');
    } catch (e, stack) {
      log("Falha no envio ao Supabase (mas salvo localmente): $e\n$stack");
    }
  }

  // Sincroniza automaticamente a rota atual
  Future<void> _autoSyncCurrentRoute() async {
    try {
      await getAllRotas();

      final rotaAuxiliar = listRotasLocal.firstWhere(
        (element) => element.id == currentRotaId,
      );

      await syncRota(rotaAuxiliar);
    } catch (e) {
      log("Erro ao sincronizar automaticamente: $e");
    }
  }

  // Converte lista de mapas em lista de PlaceModel
  List<PlaceModel> _convertToPlaceModelList(
    List<Map<String, dynamic>> rotasOnline,
  ) {
    int index = -1;

    return rotasOnline.map((e) {
      index++;
      return PlaceModel(
        id: index,
        dateInicial: e['data_inicio'],
        dateFinal: e['data_fim'],
        coordenadas: e['cordenadas'],
        idSistema: e['id_rota'],
      );
    }).toList();
  }

  // Processa nova localização no rastreamento
  Future<void> _processNewLocation(
    PlaceModel newLocal,
    String userName,
  ) async {
    final newLatLng = LatLng(
      newLocal.latitude ?? 0.0,
      newLocal.longitude ?? 0.0,
    );

    // Calcula distância percorrida
    if (lastPosition != null) {
      final distance = const Distance().as(
        LengthUnit.Meter,
        lastPosition!,
        newLatLng,
      );
      changeDistance(distance);
    }

    // Atualiza estado
    lastPosition = newLatLng;
    lastPlace = newLocal;
    addressLabel = newLocal.adress ?? 'Endereço não encontrado';

    // Salva localização
    await trackLocation(newLocal, userName);

    // Mantém histórico
    trackListLoop.insert(0, newLocal);

    // Valida cercas
    await validarDentroDeAlgumaCerca(newLatLng);
  }

  // Inicia o processo de rastreamento
  Future<void> _iniciarRastreamento(String userName) async {
    final newLocal = await _locationHelper.actuallyPosition();

    if (newLocal == null) {
      toggleTrackingState();
      trackingLoop = false;
      return;
    }

    // Inicializa rota se necessário
    if (currentRotaId == null) {
      await insertTracking(newLocal);
    }

    // Atualiza estado inicial
    lastPlace = newLocal;
    lastPosition = LatLng(
      newLocal.latitude ?? 0.0,
      newLocal.longitude ?? 0.0,
    );
    addressLabel = newLocal.adress ?? 'Endereço não encontrado';
    trackListLoop.insert(0, newLocal);

    // Salva dados para o background service
    await _saveTrackingPreferences(userName);

    // Primeira leitura imediata
    await _trackOnce(userName);

    // Inicia serviço em background
    await BackgroundLocationService.startService();

    // Inicia loop contínuo
    await _startTrackingLoop(userName);
  }

  // Para o processo de rastreamento
  Future<void> _pararRastreamento() async {
    if (trackListLoop.isNotEmpty) {
      await stopTracking(trackListLoop.first);
    }

    await BackgroundLocationService.stopService();

    _stopSharing();
    stopTrackingLoop();

    // Limpa estado
    trackListLoop.clear();
    addressLabel = '';
    lastPlace = null;
    lastPosition = null;
    distanceMeters = 0.0;
  }

  // Salva preferências de rastreamento
  Future<void> _saveTrackingPreferences(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', _supabase.auth.currentUser?.id ?? '');
    await prefs.setString('user_name', userName);
    await prefs.setInt('tracking_interval', trackingInterval);
  }

  // Finaliza compartilhamento
  void _stopSharing() {
    temp?.cancel();
    temp = null;
    trackingMode = false;
    log('Rastreamento finalizado');
  }
}
