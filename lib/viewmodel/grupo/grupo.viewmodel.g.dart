// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grupo.viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GrupoViewModel on GrupoViewModelBase, Store {
  late final _$gruposAtom =
      Atom(name: 'GrupoViewModelBase.grupos', context: context);

  @override
  ObservableList<Group> get grupos {
    _$gruposAtom.reportRead();
    return super.grupos;
  }

  @override
  set grupos(ObservableList<Group> value) {
    _$gruposAtom.reportWrite(value, super.grupos, () {
      super.grupos = value;
    });
  }

  late final _$membersAtom =
      Atom(name: 'GrupoViewModelBase.members', context: context);

  @override
  ObservableList<GroupMember> get members {
    _$membersAtom.reportRead();
    return super.members;
  }

  @override
  set members(ObservableList<GroupMember> value) {
    _$membersAtom.reportWrite(value, super.members, () {
      super.members = value;
    });
  }

  late final _$loadingAtom =
      Atom(name: 'GrupoViewModelBase.loading', context: context);

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: 'GrupoViewModelBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$carregarGruposAsyncAction =
      AsyncAction('GrupoViewModelBase.carregarGrupos', context: context);

  @override
  Future<void> carregarGrupos() {
    return _$carregarGruposAsyncAction.run(() => super.carregarGrupos());
  }

  late final _$carregarMembrosAsyncAction =
      AsyncAction('GrupoViewModelBase.carregarMembros', context: context);

  @override
  Future<void> carregarMembros(String grupoId) {
    return _$carregarMembrosAsyncAction
        .run(() => super.carregarMembros(grupoId));
  }

  late final _$obterMessageIdsDoGrupoAsyncAction = AsyncAction(
      'GrupoViewModelBase.obterMessageIdsDoGrupo',
      context: context);

  @override
  Future<List<String>> obterMessageIdsDoGrupo(String grupoId) {
    return _$obterMessageIdsDoGrupoAsyncAction
        .run(() => super.obterMessageIdsDoGrupo(grupoId));
  }

  late final _$criarGrupoAsyncAction =
      AsyncAction('GrupoViewModelBase.criarGrupo', context: context);

  @override
  Future<Group?> criarGrupo(String nome,
      {String? descricao, bool aberto = false}) {
    return _$criarGrupoAsyncAction.run(
        () => super.criarGrupo(nome, descricao: descricao, aberto: aberto));
  }

  late final _$entrarPorCodigoAsyncAction =
      AsyncAction('GrupoViewModelBase.entrarPorCodigo', context: context);

  @override
  Future<bool> entrarPorCodigo(String codigo) {
    return _$entrarPorCodigoAsyncAction
        .run(() => super.entrarPorCodigo(codigo));
  }

  late final _$removerMembroAsyncAction =
      AsyncAction('GrupoViewModelBase.removerMembro', context: context);

  @override
  Future<void> removerMembro(String grupoId, String membroId) {
    return _$removerMembroAsyncAction
        .run(() => super.removerMembro(grupoId, membroId));
  }

  late final _$GrupoViewModelBaseActionController =
      ActionController(name: 'GrupoViewModelBase', context: context);

  @override
  void changeLoading(bool value) {
    final _$actionInfo = _$GrupoViewModelBaseActionController.startAction(
        name: 'GrupoViewModelBase.changeLoading');
    try {
      return super.changeLoading(value);
    } finally {
      _$GrupoViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeMembros(List<GroupMember>? newMembers) {
    final _$actionInfo = _$GrupoViewModelBaseActionController.startAction(
        name: 'GrupoViewModelBase.changeMembros');
    try {
      return super.changeMembros(newMembers);
    } finally {
      _$GrupoViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
grupos: ${grupos},
members: ${members},
loading: ${loading},
errorMessage: ${errorMessage}
    ''';
  }
}
