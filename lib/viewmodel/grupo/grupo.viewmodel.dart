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
  late final GroupRepositorySupabase _repo;
  late final GrupoLocalRepository _localRepo;

  GrupoViewModelBase(this.loginVM) {
    _repo = GroupRepositorySupabase(_client);
    _localRepo = GrupoLocalRepository();
  }

  // ID do usuário atual
  String? get userId =>
      loginVM.loginUser?.uidUsuario ?? _client.auth.currentUser?.id;

  @observable
  ObservableList<Group> grupos = ObservableList<Group>();

  @observable
  ObservableList<GroupMember> members = ObservableList<GroupMember>();

  @observable
  bool loading = false;

  @observable
  String? errorMessage;

  @action
  void changeLoading(bool value) => loading = value;

  @action
  void changeMembros(List<GroupMember>? newMembers) {
    members = ObservableList.of(newMembers ?? []);
  }

  // Carrega todos os grupos do usuário
  // Tenta buscar do Supabase primeiro, em caso de erro usa o cache local
  @action
  Future<void> carregarGrupos() async {
    if (userId == null) {
      changeLoading(false);
      return;
    }

    changeLoading(true);
    errorMessage = null;

    try {
      grupos.clear();

      // Busca dados online do Supabase
      final result = await _repo.listGroupsForUser(userId!);

      // Carrega membros de cada grupo
      for (var grupo in result) {
        grupo.membros = await _repo.listMembers(grupo.id);
      }

      // Sincroniza com cache local
      if (result.isNotEmpty) {
        await _syncGroupsToLocal(result);
        log('${result.length} grupos sincronizados');
      }

      grupos = ObservableList.of(result);
    } catch (e) {
      errorMessage = e.toString();
      log("Erro ao carregar grupos online: $e");

      // Fallback: tenta carregar do cache local
      await _loadGroupsFromLocal();
    } finally {
      changeLoading(false);
    }
  }

  // Carrega os membros de um grupo específico
  @action
  Future<void> carregarMembros(String grupoId) async {
    loading = true;

    try {
      final result = await _repo.listMembers(grupoId);
      members = ObservableList.of(result);
    } catch (e) {
      errorMessage = e.toString();
      log("Erro ao carregar membros: $e");
    } finally {
      loading = false;
    }
  }

  // Retorna os message IDs (OneSignal) dos membros do grupo
  @action
  Future<List<String>> obterMessageIdsDoGrupo(String grupoId) async {
    try {
      return await _repo.getGroupMemberMessageIds(grupoId);
    } catch (e) {
      log("Erro ao obter message_ids do grupo: $e");
      return [];
    }
  }

  // Cria um novo grupo
  // Retorna o grupo criado ou null em caso de erro
  @action
  Future<Group?> criarGrupo(
    String nome, {
    String? descricao,
    bool aberto = false,
  }) async {
    if (userId == null) return null;

    loading = true;

    try {
      final group = await _repo.createGroup(
        nome: nome,
        descricao: descricao,
        criadoPor: userId!,
        aberto: aberto,
      );

      // Cria registro de cercas para o grupo
      final cercaRepo = CercaSupabaseRepository(_client);
      await cercaRepo.criarRegistroCercasGrupoRemoto(group.id, userId!);

      grupos.insert(0, group);
      return group;
    } catch (e) {
      errorMessage = e.toString();
      log("Erro ao criar grupo: $e");
      return null;
    } finally {
      loading = false;
    }
  }

  // Entra em um grupo usando código de convite
  // Retorna true se entrou com sucesso
  @action
  Future<bool> entrarPorCodigo(String codigo) async {
    if (userId == null) return false;

    loading = true;

    try {
      final group = await _repo.getGroupByCode(codigo);

      if (group == null) {
        throw Exception('Código inválido');
      }

      await _repo.addMember(
        grupoId: group.id,
        userId: userId!,
        adicionadoPor: userId!,
      );

      await carregarGrupos();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      log("Erro ao entrar no grupo: $e");
      return false;
    } finally {
      loading = false;
    }
  }

  // Remove um membro de um grupo
  @action
  Future<void> removerMembro(String grupoId, String membroId) async {
    if (userId == null) return;

    loading = true;

    try {
      await _repo.removeMember(grupoId: grupoId, userId: membroId);
      members.removeWhere((m) => m.userId == membroId);
    } catch (e) {
      errorMessage = e.toString();
      log("Erro ao remover membro: $e");
    } finally {
      loading = false;
    }
  }

  // Sincroniza grupos com o cache local (SQLite)
  Future<void> _syncGroupsToLocal(List<Group> groups) async {
    try {
      await _localRepo.limparTabelasGrupos();
      await _localRepo.salvarGrupos(groups);

      for (var grupo in groups) {
        if (grupo.membros != null && grupo.membros!.isNotEmpty) {
          await _localRepo.salvarMembrosGrupo(grupo.id, grupo.membros!);
        }
      }

      log('Dados sincronizados com SQLite local');
    } catch (e) {
      log("Erro ao sincronizar com SQLite: $e");
    }
  }

  // Carrega grupos do cache local
  Future<void> _loadGroupsFromLocal() async {
    try {
      log('Tentando carregar grupos do cache local...');
      final localGrupos = await _localRepo.carregarGrupos();
      grupos = ObservableList.of(localGrupos);
      log('${localGrupos.length} grupos carregados do cache local');
    } catch (localError) {
      log("Erro ao carregar do cache local: $localError");
    }
  }
}
