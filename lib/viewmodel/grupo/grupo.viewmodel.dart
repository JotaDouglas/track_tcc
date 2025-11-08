import 'dart:developer';

import 'package:mobx/mobx.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/model/grupo/grupo.model.dart';
import 'package:track_tcc_app/model/grupo/membros.model.dart';
import 'package:track_tcc_app/repository/cerca.repository.dart';
import 'package:track_tcc_app/repository/grupo/grupo.supabase.repository.dart';
import 'package:track_tcc_app/repository/grupo/grupo.local.repository.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

part 'grupo.viewmodel.g.dart';

class GrupoViewModel = GrupoViewModelBase with _$GrupoViewModel;

abstract class GrupoViewModelBase with Store {
  final LoginViewModel loginVM;
  final SupabaseClient _client = Supabase.instance.client;
  late GroupRepositorySupabase _repo;
  late GrupoLocalRepository _localRepo;

  GrupoViewModelBase(this.loginVM) {
    _repo = GroupRepositorySupabase(_client);
    _localRepo = GrupoLocalRepository();
  }

  String? get userId =>
      loginVM.loginUser?.uidUsuario ?? _client.auth.currentUser?.id;

  @observable
  ObservableList<Group> grupos = ObservableList<Group>();

  // 🔹 Adicionando o campo que a tela usa:
  @observable
  ObservableList<GroupMember> members = ObservableList<GroupMember>();

  @observable
  bool loading = false;

  @observable
  String? errorMessage;

  @action
  void changeLoading(bool value) => loading = value;

  @action
  Future<void> carregarGrupos() async {
    if (userId == null) {
      changeLoading(false);
      return;
    }

    changeLoading(true);

    errorMessage = null;

    try {
      // Limpa a lista de grupos antes de buscar novos dados
      grupos.clear();

      // 1️⃣ Busca dados atualizados do Supabase
      final result = await _repo.listGroupsForUser(userId!);

      // Carrega os membros de cada grupo
      for (var g in result) {
        g.membros = await _repo.listMembers(g.id);
      }

      // 2️⃣ Se houver dados do Supabase, limpa e atualiza o SQLite
      if (result.isNotEmpty) {
        log('📥 ${result.length} grupos recebidos do Supabase');

        // Limpa as tabelas locais antes de inserir novos dados
        await _localRepo.limparTabelasGrupos();

        // Salva os grupos no SQLite
        await _localRepo.salvarGrupos(result);

        // Salva os membros de cada grupo no SQLite
        for (var grupo in result) {
          if (grupo.membros != null && grupo.membros!.isNotEmpty) {
            await _localRepo.salvarMembrosGrupo(grupo.id, grupo.membros!);
          }
        }

        log('✅ Dados sincronizados com SQLite local');
      }

      // 3️⃣ Atualiza a lista observável com os novos dados
      grupos = ObservableList.of(result);
    } catch (e) {
      errorMessage = e.toString();
      log("⚠️ Erro ao carregar grupos online: $e");

      // 4️⃣ Em caso de erro, tenta carregar do cache local
      try {
        log('🔄 Tentando carregar grupos do cache local...');
        final localGrupos = await _localRepo.carregarGrupos();
        grupos = ObservableList.of(localGrupos);
        log('📖 ${localGrupos.length} grupos carregados do cache local');
      } catch (localError) {
        log("❌ Erro ao carregar do cache local: $localError");
      }
    } finally {
      // Garante que o loading sempre será desativado
      changeLoading(false);
    }
  }

  @action
  changeMembros(List<GroupMember>? m) => members = ObservableList.of(m ?? []);

  @action
  Future<Group?> criarGrupo(String nome,
      {String? descricao, bool aberto = false}) async {
    if (userId == null) return null;
    loading = true;
    try {
      final group = await _repo.createGroup(
        nome: nome,
        descricao: descricao,
        criadoPor: userId!,
        aberto: aberto,
      );

      // 🔹 Cria linha na tabela 'cercas'
      final cercaRepo = CercaSupabaseRepository(_client);
      await cercaRepo.criarRegistroGrupo(group.id, userId!);

      grupos.insert(0, group);
      return group;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      loading = false;
    }
  }

  @action
  Future<bool> entrarPorCodigo(String codigo) async {
    if (userId == null) return false;
    loading = true;
    try {
      final group = await _repo.getGroupByCode(codigo);
      if (group == null) throw Exception('Código inválido');
      await _repo.addMember(
          grupoId: group.id, userId: userId!, adicionadoPor: userId!);
      await carregarGrupos();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      loading = false;
    }
  }

  // 🔹 Novo método para carregar os membros do grupo:
  @action
  Future<void> carregarMembros(String grupoId) async {
    loading = true;
    try {
      final result = await _repo.listMembers(grupoId);
      members = ObservableList.of(result);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> removerMembro(String grupoId, String membroId) async {
    if (userId == null) return;
    loading = true;
    try {
      await _repo.removeMember(grupoId: grupoId, userId: membroId);
      members.removeWhere((m) => m.userId == membroId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
    }
  }

  /// Retorna todos os message_ids (OneSignal player IDs) dos membros de um grupo
  /// excluindo o usuário atual
  @action
  Future<List<String>> obterMessageIdsDoGrupo(String grupoId) async {
    try {
      return await _repo.getGroupMemberMessageIds(grupoId);
    } catch (e) {
      log("⚠️ Erro ao obter message_ids do grupo: $e");
      return [];
    }
  }
}
