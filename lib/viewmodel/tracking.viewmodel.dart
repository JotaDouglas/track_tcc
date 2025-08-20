import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:latlong2/latlong.dart';
import 'package:mobx/mobx.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/helper/location.helper.dart';
import 'package:track_tcc_app/model/place.model.dart';
import 'package:track_tcc_app/repository/track.repository.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

part 'tracking.viewmodel.g.dart';

class TrackingViewModel = TrackingViewModelBase with _$TrackingViewModel;

abstract class TrackingViewModelBase with Store {
  final TrackRepository trackRepository = TrackRepository();
  final SupabaseClient _supabase = Supabase.instance.client;
  final Locationhelper _locationHelper = Locationhelper();
  final LoginViewModel authViewModel = LoginViewModel();

  int? currentRotaId;

  @observable
  ObservableList<PlaceModel> trackList = ObservableList<PlaceModel>();

  @observable
  List<PlaceModel> listRotasOnline = [];

  @observable
  List<PlaceModel> listRotasLocal = [];

  @observable
  bool loading = false;

  //Sistema de track

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

  @action
  changeDistance(double value, {bool reset = false}) {
    distanceMeters += value;

    if (reset) {
      distanceMeters = 0.0;
    }
  }

  @action
  changeLoading(bool value) => loading = value;

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

  @action
  Future<void> removeRota(int rotaId) async {
    await trackRepository.deleteRota(rotaId);
  }

  @action
  Future<void> trackLocation(PlaceModel location, String name) async {
    if (currentRotaId == null) {
      log('Erro: currentRotaId é nulo. Não foi iniciado insertTracking?');
      return;
    }

    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) {
        log('Usuário não autenticado');
        return;
      }

      trackList.insert(0, location);
      await trackRepository.insertRotaPoint(currentRotaId!, location);

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
      log("Erro ao rastrear localização: $e\n$stack");
    }
  }

  @action
  Future<void> stopTracking(PlaceModel finalLocation) async {
    if (currentRotaId == null) {
      log('Rastreamento já estava parado.');
      return;
    }

    try {
      await trackRepository.updateRotaFinal(currentRotaId!, finalLocation);
      final uid = _supabase.auth.currentUser?.id;
      if (uid != null) {
        await _supabase.from('localizacoes').delete().eq("user_id", uid);
        log('Localização final removida do Supabase');
      }

      //Processo de sincronizar a rota online após finalizar o trajeto
      try {
        await getAllRotas();
        PlaceModel rotaAuxiliar = listRotasLocal.firstWhere(
          (element) {
            return element.id == currentRotaId;
          },
        );

        syncRota(rotaAuxiliar);
      } catch (e) {
        log("erro ao sincronizar automaticamente");
      }

      currentRotaId = null;
    } catch (e) {
      log("Erro ao parar rastreamento: $e");
    }
  }

  @action
  Future<bool> syncRota(PlaceModel rota) async {
    try {
      if (rota.id == null || rota.idSistema != null) return false;

      final uid = _supabase.auth.currentUser?.id;
      //Criar o json com todos os pontos da rota
      var trajetoJson = await trackRepository.gerarJsonRotasComPontos(rota.id!);

      //Criar o corpo do arquivo para realizar o insert
      var dados = {
        "user_id": uid,
        "data_inicio": rota.dateInicial,
        "data_fim": rota.dateFinal ?? DateTime.now().toString(),
        "cordenadas": trajetoJson,
      };

      bool res = await trackRepository.syncRotas(dados, rota.id!);

      if (res) {
        await removeRota(rota.id ?? -1);
        getAllRotas();
        getRotasOnline();
      }

      return res;
    } catch (e) {
      return false;
    }
  }

  Future getAllRotas() async {
    List<PlaceModel> rotasAux = await trackRepository.getAllRotas();
    listRotasLocal = List.from(rotasAux);
  }

  Future<List<PlaceModel>> getPontosByRota(int rotaId) async {
    return await trackRepository.getPontosByRotaId(rotaId);
  }

  @action
  Future getRotasOnline() async {
    changeLoading(true);

    final uid = _supabase.auth.currentUser?.id;
    List<Map<String, dynamic>> rotasOnline =
        await trackRepository.getRotasOnline(uid!);

    int index = -1;

    //converter o response em objeto do tipo placemodel
    List<PlaceModel> aux = rotasOnline.map(
      (e) {
        index++;
        return PlaceModel(
          id: index,
          dateInicial: e['data_inicio'],
          dateFinal: e['data_fim'],
          coordenadas: e['cordenadas'],
          idSistema: e['id_rota'],
        );
      },
    ).toList();

    //reordenar a lista

    listRotasOnline = List.from(aux);

    if (listRotasOnline.isNotEmpty) {
      listRotasOnline.sort(
        (a, b) => b.id!.compareTo(a.id!),
      );
    }

    changeLoading(false);
  }

  Future<List<PlaceModel>> readCordenadas(String cordenadas) async {
    List<PlaceModel> trajeto = [];

    if (cordenadas.isEmpty) return trajeto;

    try {
      var decoded = jsonDecode(cordenadas);

      //criar variavel auxiliar para converter os pontos
      var posicoes = decoded[0]['pontos'];

      for (var p in posicoes) {
        trajeto.add(PlaceModel(
          id: p['id'],
          latitude: p['latitude'],
          longitude: p['longitude'],
          dateInicial: p['data'],
        ));
      }
    } catch (e) {
      log("Erro ao converter as coordenadas");
    }

    return trajeto;
  }

  Future deleteRotaOnline(String id) async {
    changeLoading(true);

    await trackRepository.deleteRotaOnline(id);
    getRotasOnline();

    changeLoading(false);
  }

  //Sistema de tracking
  Future<void> _startSharing() async {
    //Sinal GPS
    bool gpsOn;
    gpsOn = await Locationhelper().checkGps(context);
    if (gpsOn != true) return;

    toggleTrackingState();

    trackingMode = trackingLoop;
    changeDistance(0, reset: true);

    if (trackingLoop) {
      final newLocal = await _locationHelper.actuallyPosition();

      if (newLocal != null) {
        if (currentRotaId == null) {
          await insertTracking(newLocal);
        }

        lastPlace = newLocal;
        lastPosition =
            LatLng(newLocal.latitude ?? 0.0, newLocal.longitude ?? 0.0);
        addressLabel = newLocal.adress ?? 'Endereço não encontrado';

        trackListLoop.insert(0, newLocal);

        primeiroTrack(); // faz a primeira leitura
        _startTimer(); // começa o timer para continuar rastreando
      } else {
        toggleTrackingState();
        trackingLoop = false;
      }
    } else {
      if (trackListLoop.isNotEmpty) {
        await stopTracking(trackListLoop.first);
      }

      _stopSharing();
      trackListLoop.clear();
      addressLabel = '';
      lastPlace = null;
      lastPosition = null;
      distanceMeters = 0.0;
    }
  }

  toggleTrackingState() {
    trackingLoop = !trackingLoop;
  }

  Future<void> primeiroTrack() async {
    try {
      final newLocal = await _locationHelper.actuallyPosition();

      if (newLocal != null) {
        // Calcular distância
        final newLatLng =
            LatLng(newLocal.latitude ?? 0.0, newLocal.longitude ?? 0.0);
        if (lastPosition != null) {
          distanceMeters += const Distance().as(
            LengthUnit.Meter,
            lastPosition!,
            newLatLng,
          );
        }

        lastPosition = newLatLng;
        lastPlace = newLocal;
        addressLabel = newLocal.adress ?? 'Endereço não encontrado';

        await trackLocation(newLocal, authViewModel.loginUser?.username  ?? 'Sem nome');

        trackListLoop.insert(0, newLocal);
      } else {
        log('Localização retornou null.');
      }
    } catch (e) {
      log('Erro no rastreamento: $e');
      _stopSharing();
      toggleTrackingState();
    }
  }

  void _startTimer() async {
    temp = Timer.periodic(const Duration(seconds: 5), (_) => primeiroTrack());
  }

  void _stopSharing() async {
    temp?.cancel();
    temp = null;
    log('Rastreamento finalizado');
    trackingMode = false;
  }
}
