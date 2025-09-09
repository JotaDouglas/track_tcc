// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geofence.viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GeofenceStore on _GeofenceStoreBase, Store {
  late final _$pontosAtom =
      Atom(name: '_GeofenceStoreBase.pontos', context: context);

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

  late final _$_GeofenceStoreBaseActionController =
      ActionController(name: '_GeofenceStoreBase', context: context);

  @override
  void adicionarPonto(LatLng ponto) {
    final _$actionInfo = _$_GeofenceStoreBaseActionController.startAction(
        name: '_GeofenceStoreBase.adicionarPonto');
    try {
      return super.adicionarPonto(ponto);
    } finally {
      _$_GeofenceStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void limparPontos() {
    final _$actionInfo = _$_GeofenceStoreBaseActionController.startAction(
        name: '_GeofenceStoreBase.limparPontos');
    try {
      return super.limparPontos();
    } finally {
      _$_GeofenceStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removerPonto(int index) {
    final _$actionInfo = _$_GeofenceStoreBaseActionController.startAction(
        name: '_GeofenceStoreBase.removerPonto');
    try {
      return super.removerPonto(index);
    } finally {
      _$_GeofenceStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pontos: ${pontos}
    ''';
  }
}
