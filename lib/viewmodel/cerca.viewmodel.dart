import 'dart:developer';
import 'package:mobx/mobx.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  ObservableMap<String, List<LatLng>> cercasMap =
      ObservableMap<String, List<LatLng>>();

  @observable
  String? cercaAtual;

  @observable
  String modo = 'visualizar'; // criar, editar, visualizar

  @observable
  String? grupoIdSelecionado;

  @action
  Future<void> carregarTodasCercasLocais() async {
    cercasMap.clear();
    for (var nome in cercasSalvas) {
      final carregados = await _cercaRepository.carregarCerca(nome);
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
      await _cercaRepository.salvarCerca(nome, pontos);
    }

    await listarCercas(); // atualiza a listagem local
    log("✅ Cercas do grupo $grupoId sincronizadas no SQLite");
  }

  // =====================================================================
  // 🔹 Carregar cercas de um grupo (online → cache local → memória)
  // =====================================================================
  @action
  Future<void> carregarCercasGrupo(String grupoId) async {
    grupoIdSelecionado = grupoId;
    try {
      log('🔹 Carregando cercas do grupo $grupoId...');
      // 1️⃣ Busca online do Supabase
      final onlineMapa = await _cercaSupabaseRepo.getCercasPorGrupo(grupoId);

      // 2️⃣ Atualiza cache local
      await _cercaRepository.upsertCercasGrupo(
        grupoId,
        onlineMapa,
        atualizadoEm: DateTime.now().toIso8601String(),
        syncStatus: 'synced',
      );

      // 3️⃣ Carrega do cache local
      final locais = await _cercaRepository.getCercasGrupo(grupoId);
      cercasMap
        ..clear()
        ..addAll(locais);

      modo = 'visualizar_todas';
      log('✅ Cercas carregadas e sincronizadas: ${cercasMap.keys}');
    } catch (e) {
      log('⚠️ Erro ao carregar cercas online, usando cache local: $e');
      final locais = await _cercaRepository.getCercasGrupo(grupoId);
      cercasMap
        ..clear()
        ..addAll(locais);
      modo = 'visualizar_todas';
      log('🔸 Cercas carregadas do cache local: ${cercasMap.keys}');
    }
  }

  // =====================================================================
  // 🔹 Salvar uma cerca no grupo (SQLite + Supabase)
  // =====================================================================
  @action
  Future<void> salvarCercaGrupo(String nome, String userId) async {
    if (grupoIdSelecionado == null) {
      log('❌ Nenhum grupo selecionado para salvar a cerca.');
      return;
    }

    final grupoId = grupoIdSelecionado!;
    final pontosCerca = pontos.toList();

    // 1️⃣ Atualiza cache local primeiro
    await _cercaRepository.saveSingleCercaLocal(grupoId, nome, pontosCerca,
        syncStatus: 'pending');

    // 2️⃣ Atualiza memória (MobX)
    cercasMap[nome] = pontosCerca;
    cercaAtual = nome;
    log('🧩 Cerca "$nome" salva localmente (pending sync)');

    // 3️⃣ Tenta sincronizar com o Supabase
    try {
      await _cercaSupabaseRepo.salvarCercas(grupoId, cercasMap, userId);
      await _cercaRepository.upsertCercasGrupo(
        grupoId,
        cercasMap,
        atualizadoEm: DateTime.now().toIso8601String(),
        syncStatus: 'synced',
      );
      log('✅ Cerca "$nome" sincronizada com o Supabase');
    } catch (e) {
      await _cercaRepository.markGrupoPending(grupoId);
      log('⚠️ Falha ao sincronizar com o Supabase: $e (mantida como pending)');
    }
  }

  // =====================================================================
  // 🔹 Métodos locais (herdados do SQLite individual)
  // =====================================================================
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
  Future<void> salvarCercaLocal(String nome) async {
    await _cercaRepository.salvarCerca(nome, pontos.toList());
    cercaAtual = nome;
    await listarCercas();
  }

  @action
  Future<void> carregarCercaLocal(String nome) async {
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
  Future<void> carregarTodasCercas() async {
    cercasMap.clear();
    for (var nome in cercasSalvas) {
      final carregados = await _cercaRepository.carregarCerca(nome);
      if (carregados != null) {
        cercasMap[nome] = carregados;
      }
    }
  }

  @action
  Future<void> deletarCercaLocal(String nome) async {
    await _cercaRepository.deletarCerca(nome);
    if (cercaAtual == nome) {
      limparPontos();
      cercaAtual = null;
    }
    await listarCercas();
  }

  // =====================================================================
  // 🔹 Controle de modo de edição / visualização
  // =====================================================================
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

  // =====================================================================
  // 🔹 Sincronização pendente (ex: ao reconectar)
  // =====================================================================
  Future<void> sincronizarPendentes(String userId) async {
    final pendentes = await _cercaRepository.getPendingGroups();
    for (final p in pendentes) {
      final grupoId = p['grupo_id'] as String;
      final geoData = p['geo_data'] as String;
      try {
        final decoded = await _cercaRepository.getCercasGrupo(grupoId);
        await _cercaSupabaseRepo.salvarCercas(grupoId, decoded, userId);
        await _cercaRepository.upsertCercasGrupo(
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
}
