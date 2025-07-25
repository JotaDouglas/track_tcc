import 'dart:developer';

import 'package:mobx/mobx.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/model/place.model.dart';
import 'package:track_tcc_app/repository/track.repository.dart';

part 'tracking.viewmodel.g.dart';

class TrackingViewModel = TrackingViewModelBase with _$TrackingViewModel;

abstract class TrackingViewModelBase with Store {
  final TrackRepository trackRepository = TrackRepository();
  final SupabaseClient _supabase = Supabase.instance.client;

  int? currentRotaId;

  @observable
  ObservableList<PlaceModel> trackList = ObservableList<PlaceModel>();

  @observable
  List<PlaceModel> listRotas = [];

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
      currentRotaId = null;
    } catch (e) {
      log("Erro ao parar rastreamento: $e");
    }
  }

  @action
  Future<bool> syncRota(PlaceModel rota) async {
    try {
      if(rota.id == null || rota.idSistema != null) return false;

      final uid = _supabase.auth.currentUser?.id;
      //Criar o json com todos os pontos da rota
      var trajetoJson = await trackRepository.gerarJsonRotasComPontos(rota.id!);

      //Criar o corpo do arquivo para realizar o insert
      var dados = {
        "user_id": uid,
        "data_inicio": rota.dateInicial,
        "data_fim": rota.dateFinal,
        "cordenadas": trajetoJson,
      };

      bool res = await trackRepository.syncRotas(dados, rota.id!);

      return res;
    } catch (e) {
      return false;
    }
  }

  Future<List<PlaceModel>> getAllRotas() async {
    return await trackRepository.getAllRotas();
  }

  Future<List<PlaceModel>> getPontosByRota(int rotaId) async {
    return await trackRepository.getPontosByRotaId(rotaId);
  }
}
