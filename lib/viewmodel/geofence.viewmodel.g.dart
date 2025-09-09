// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geofence.viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GeofenceStore on _GeofenceStoreBase, Store {
  late final _$quadradosAtom =
      Atom(name: '_GeofenceStoreBase.quadrados', context: context);

  @override
  ObservableList<List<LatLng>> get quadrados {
    _$quadradosAtom.reportRead();
    return super.quadrados;
  }

  @override
  set quadrados(ObservableList<List<LatLng>> value) {
    _$quadradosAtom.reportWrite(value, super.quadrados, () {
      super.quadrados = value;
    });
  }

  late final _$_GeofenceStoreBaseActionController =
      ActionController(name: '_GeofenceStoreBase', context: context);

  @override
  void adicionarQuadrado(LatLng center, {double delta = 0.001}) {
    final _$actionInfo = _$_GeofenceStoreBaseActionController.startAction(
        name: '_GeofenceStoreBase.adicionarQuadrado');
    try {
      return super.adicionarQuadrado(center, delta: delta);
    } finally {
      _$_GeofenceStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void limparQuadrados() {
    final _$actionInfo = _$_GeofenceStoreBaseActionController.startAction(
        name: '_GeofenceStoreBase.limparQuadrados');
    try {
      return super.limparQuadrados();
    } finally {
      _$_GeofenceStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
quadrados: ${quadrados}
    ''';
  }
}
