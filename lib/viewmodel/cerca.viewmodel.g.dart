// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cerca.viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CercaViewModel on CercaViewModelBase, Store {
  late final _$pontosAtom =
      Atom(name: 'CercaViewModelBase.pontos', context: context);

  @override
  ObservableList<LatLng> get pontos {
    _$pontosAtom.reportRead();
    return super.pontos;
  }

  @override
  set pontos(ObservableList<LatLng> value) {
    _$pontosAtom.reportWrite(value, super.pontos, () {
      super.pontos = value;
    });
  }

  late final _$cercasSalvasAtom =
      Atom(name: 'CercaViewModelBase.cercasSalvas', context: context);

  @override
  ObservableList<String> get cercasSalvas {
    _$cercasSalvasAtom.reportRead();
    return super.cercasSalvas;
  }

  @override
  set cercasSalvas(ObservableList<String> value) {
    _$cercasSalvasAtom.reportWrite(value, super.cercasSalvas, () {
      super.cercasSalvas = value;
    });
  }

  late final _$cercasMapAtom =
      Atom(name: 'CercaViewModelBase.cercasMap', context: context);

  @override
  ObservableMap<String, List<LatLng>> get cercasMap {
    _$cercasMapAtom.reportRead();
    return super.cercasMap;
  }

  @override
  set cercasMap(ObservableMap<String, List<LatLng>> value) {
    _$cercasMapAtom.reportWrite(value, super.cercasMap, () {
      super.cercasMap = value;
    });
  }

  late final _$cercaAtualAtom =
      Atom(name: 'CercaViewModelBase.cercaAtual', context: context);

  @override
  String? get cercaAtual {
    _$cercaAtualAtom.reportRead();
    return super.cercaAtual;
  }

  @override
  set cercaAtual(String? value) {
    _$cercaAtualAtom.reportWrite(value, super.cercaAtual, () {
      super.cercaAtual = value;
    });
  }

  late final _$modoAtom =
      Atom(name: 'CercaViewModelBase.modo', context: context);

  @override
  String get modo {
    _$modoAtom.reportRead();
    return super.modo;
  }

  @override
  set modo(String value) {
    _$modoAtom.reportWrite(value, super.modo, () {
      super.modo = value;
    });
  }

  late final _$salvarCercaAsyncAction =
      AsyncAction('CercaViewModelBase.salvarCerca', context: context);

  @override
  Future<void> salvarCerca(String nome) {
    return _$salvarCercaAsyncAction.run(() => super.salvarCerca(nome));
  }

  late final _$carregarCercaAsyncAction =
      AsyncAction('CercaViewModelBase.carregarCerca', context: context);

  @override
  Future<void> carregarCerca(String nome) {
    return _$carregarCercaAsyncAction.run(() => super.carregarCerca(nome));
  }

  late final _$listarCercasAsyncAction =
      AsyncAction('CercaViewModelBase.listarCercas', context: context);

  @override
  Future<void> listarCercas() {
    return _$listarCercasAsyncAction.run(() => super.listarCercas());
  }

  late final _$deletarCercaAsyncAction =
      AsyncAction('CercaViewModelBase.deletarCerca', context: context);

  @override
  Future<void> deletarCerca(String nome) {
    return _$deletarCercaAsyncAction.run(() => super.deletarCerca(nome));
  }

  late final _$editarCercaAsyncAction =
      AsyncAction('CercaViewModelBase.editarCerca', context: context);

  @override
  Future<void> editarCerca(String nome) {
    return _$editarCercaAsyncAction.run(() => super.editarCerca(nome));
  }

  late final _$carregarTodasCercasAsyncAction =
      AsyncAction('CercaViewModelBase.carregarTodasCercas', context: context);

  @override
  Future<void> carregarTodasCercas() {
    return _$carregarTodasCercasAsyncAction
        .run(() => super.carregarTodasCercas());
  }

  late final _$CercaViewModelBaseActionController =
      ActionController(name: 'CercaViewModelBase', context: context);

  @override
  void adicionarPonto(LatLng ponto) {
    final _$actionInfo = _$CercaViewModelBaseActionController.startAction(
        name: 'CercaViewModelBase.adicionarPonto');
    try {
      return super.adicionarPonto(ponto);
    } finally {
      _$CercaViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removerPonto(int index) {
    final _$actionInfo = _$CercaViewModelBaseActionController.startAction(
        name: 'CercaViewModelBase.removerPonto');
    try {
      return super.removerPonto(index);
    } finally {
      _$CercaViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void limparPontos() {
    final _$actionInfo = _$CercaViewModelBaseActionController.startAction(
        name: 'CercaViewModelBase.limparPontos');
    try {
      return super.limparPontos();
    } finally {
      _$CercaViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void iniciarNovaCerca() {
    final _$actionInfo = _$CercaViewModelBaseActionController.startAction(
        name: 'CercaViewModelBase.iniciarNovaCerca');
    try {
      return super.iniciarNovaCerca();
    } finally {
      _$CercaViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void finalizarEdicao() {
    final _$actionInfo = _$CercaViewModelBaseActionController.startAction(
        name: 'CercaViewModelBase.finalizarEdicao');
    try {
      return super.finalizarEdicao();
    } finally {
      _$CercaViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pontos: ${pontos},
cercasSalvas: ${cercasSalvas},
cercasMap: ${cercasMap},
cercaAtual: ${cercaAtual},
modo: ${modo}
    ''';
  }
}
