import 'dart:developer';

import 'package:mobx/mobx.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/model/grupo/grupo.model.dart';
import 'package:track_tcc_app/model/grupo/membros.model.dart';
import 'package:track_tcc_app/repository/cerca.repository.dart';
import 'package:track_tcc_app/repository/grupo/grupo.supabase.repository.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

part 'grupo.viewmodel.g.dart';

class GrupoViewModel = GrupoViewModelBase with _$GrupoViewModel;

abstract class GrupoViewModelBase with Store {
  final LoginViewModel loginVM;
  final SupabaseClient _client = Supabase.instance.client;
  late GroupRepositorySupabase _repo;

  GrupoViewModelBase(this.loginVM) {
    _repo = GroupRepositorySupabase(_client);
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
  Future<void> carregarGrupos() async {
    if (userId == null) return;
    loading = true;
    try {
      final result = await _repo.listGroupsForUser(userId!);
      for (var g in result) {
        g.membros = await _repo.listMembers(g.id);
      }
      grupos = ObservableList.of(result);
    } catch (e) {
      errorMessage = e.toString();
      log("Erro: $e");
    } finally {
      loading = false;
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
      members.removeWhere((m) => m?.userId == membroId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
    }
  }
}
