import 'dart:developer';

import 'package:mobx/mobx.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/model/grupo/grupo.model.dart';
import 'package:track_tcc_app/repository/cerca.repository.dart';

part 'cerca.viewmodel.g.dart';

class CercaViewModel = CercaViewModelBase with _$CercaViewModel;

abstract class CercaViewModelBase with Store {
  final CercaRepository _cercaRepository = CercaRepository();
  final CercaSupabaseRepository _cercaSupabaseRepo =
      CercaSupabaseRepository(Supabase.instance.client);

  @observable
  ObservableList<LatLng> pontos = ObservableList<LatLng>();

  @observable
  ObservableList<String> cercasSalvas = ObservableList<String>();

  @observable
  ObservableList<Group> gruposNames = ObservableList<Group>();

  @observable
  ObservableMap<String, List<LatLng>> cercasMap =
      ObservableMap<String, List<LatLng>>();

  @observable
  String? cercaAtual;

  @observable
  String modo = 'visualizar'; // criar, editar, visualizar, visualizar_todas

  @observable
  String? grupoIdSelecionado;

  @observable
  String? cercaSelecionada;

  @observable
  Group? grupoSelecionado;

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

  // Carrega cercas de um grupo (Supabase → Cache → Memória)
  // Em caso de erro, usa o cache local como fallback
  @action
  Future<void> carregarCercasGrupo(String grupoId, String? grupoName) async {
    grupoIdSelecionado = grupoId;

    try {
      log('  Carregando cercas do grupo $grupoId...');

      // Busca online do Supabase
      final onlineMapa =
          await _cercaSupabaseRepo.getCercasDoGrupoRemoto(grupoId);

      // Atualiza cache local
      await _cercaRepository.cercasCacheGrupo(
        grupoId,
        onlineMapa,
        atualizadoEm: DateTime.now().toIso8601String(),
        syncStatus: 'synced',
        grupoName: grupoName ?? '',
      );

      // Carrega do cache local para memória
      final locais = await _cercaRepository.getCercasCacheGrupo(grupoId);
      _updateCercasMap(locais);

      modo = 'visualizar_todas';
      log('✅ Cercas carregadas e sincronizadas: ${cercasMap.keys}');
    } catch (e) {
      log('⚠️ Erro ao carregar cercas online, usando cache local: $e');

      // Fallback: usa cache local
      final locais = await _cercaRepository.getCercasCacheGrupo(grupoId);
      _updateCercasMap(locais);

      modo = 'visualizar_todas';
      log('🔸 Cercas carregadas do cache local: ${cercasMap.keys}');
    }
  }

  // Salva uma cerca no grupo (SQLite + Supabase)
  @action
  Future<void> salvarCercaGrupo(String nome, String userId) async {
    if (grupoIdSelecionado == null) {
      log('❌ Nenhum grupo selecionado para salvar a cerca.');
      return;
    }

    final grupoId = grupoIdSelecionado!;
    final pontosCerca = pontos.toList();

    // Carrega cercas existentes do cache local
    final cercasExistentes =
        await _cercaRepository.getCercasCacheGrupo(grupoId);

    // Adiciona a nova cerca
    cercasExistentes[nome] = pontosCerca;

    // Atualiza cache local primeiro
    await _cercaRepository.salvarCercaNoCacheGrupo(
      grupoId,
      nome,
      pontosCerca,
      syncStatus: 'pending',
    );

    // Atualiza memória (MobX)
    _updateCercasMap(cercasExistentes);
    cercaAtual = nome;
    log('🧩 Cerca "$nome" salva localmente (pending sync)');

    // Tenta sincronizar com Supabase
    await _syncCercasToSupabase(grupoId, cercasExistentes, nome, userId);
  }

  // Sincroniza cercas pendentes ao reconectar
  Future<void> sincronizarPendentes(String userId) async {
    final pendentes = await _cercaRepository.getGruposPendentes();

    for (final p in pendentes) {
      final grupoId = p['grupo_id'] as String;

      try {
        final decoded = await _cercaRepository.getCercasCacheGrupo(grupoId);
        await _cercaSupabaseRepo.salvarCercasNoSupabase(
            grupoId, decoded, userId);

        await _cercaRepository.cercasCacheGrupo(
          grupoId,
          decoded,
          atualizadoEm: DateTime.now().toIso8601String(),
          syncStatus: 'synced',
        );

        log('✅ Grupo $grupoId sincronizado com sucesso.');
      } catch (e) {
        log('⚠️ Erro ao sincronizar grupo pendente $grupoId: $e');
      }
    }
  }

  @action
  Future<void> salvarCercaLocal(String nome) async {
    await _cercaRepository.salvarCercaIndividual(nome, pontos.toList());
    cercaAtual = nome;
    await listarCercas();
  }

  @action
  Future<void> carregarCercaLocal(String nome) async {
    final carregados = await _cercaRepository.carregarCercaIndividual(nome);

    if (carregados != null) {
      cercaAtual = nome;
      pontos
        ..clear()
        ..addAll(carregados);
    }
  }

  @action
  Future<void> deletarCercaLocal(String nome) async {
    await _cercaRepository.deletarCercaIndividual(nome);

    if (cercaAtual == nome) {
      limparPontos();
      cercaAtual = null;
    }

    await listarCercas();
  }

  @action
  Future<void> carregarTodasCercasLocais() async {
    cercasMap.clear();

    for (var nome in cercasSalvas) {
      final carregados = await _cercaRepository.carregarCercaIndividual(nome);
      if (carregados != null) {
        cercasMap[nome] = carregados;
      }
    }
  }

  @action
  Future<void> carregarTodasCercas() async {
    cercasMap.clear();

    for (var nome in cercasSalvas) {
      final carregados = await _cercaRepository.carregarCercaIndividual(nome);
      if (carregados != null) {
        cercasMap[nome] = carregados;
      }
    }
  }

  @action
  Future<void> sincronizarCercasLocais(String grupoId) async {
    if (cercasMap.isEmpty) return;

    for (var entry in cercasMap.entries) {
      final nome = entry.key;
      final pontos = entry.value;
      await _cercaRepository.salvarCercaIndividual(nome, pontos);
    }

    await listarCercas();
    log("✅ Cercas do grupo $grupoId sincronizadas no SQLite");
  }

  @action
  Future<void> listarCercas() async {
    final lista = await _cercaRepository.listarNomesCercasIndividuais();
    cercasSalvas
      ..clear()
      ..addAll(lista);
  }

  @action
  Future<void> listarGrupos() async {
    final lista = await _cercaRepository.listarGrupos();
    gruposNames
      ..clear()
      ..addAll(lista);
  }

  @action
  void iniciarNovaCerca() {
    limparPontos();
    cercaAtual = null;
    modo = 'criar';
  }

  @action
  Future<void> editarCerca(String nome) async {
    await carregarCercaLocal(nome);
    modo = 'editar';
  }

  @action
  void finalizarEdicao() {
    modo = 'visualizar';
  }

  // Atualiza o mapa de cercas na memória
  void _updateCercasMap(Map<String, List<LatLng>> novasCercas) {
    cercasMap
      ..clear()
      ..addAll(novasCercas);
  }

  // Sincroniza cercas com Supabase
  Future<void> _syncCercasToSupabase(
    String grupoId,
    Map<String, List<LatLng>> cercas,
    String nomeCerca,
    String userId,
  ) async {
    try {
      await _cercaSupabaseRepo.salvarCercasNoSupabase(grupoId, cercas, userId);

      await _cercaRepository.cercasCacheGrupo(
        grupoId,
        cercas,
        atualizadoEm: DateTime.now().toIso8601String(),
        syncStatus: 'synced',
      );

      log('✅ Cerca "$nomeCerca" sincronizada com o Supabase');
    } catch (e) {
      await _cercaRepository.marcarGrupoPendenteSync(grupoId);
      log('⚠️ Falha ao sincronizar com o Supabase: $e (mantida como pending)');
    }
  }
}
