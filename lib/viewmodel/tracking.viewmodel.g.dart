// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking.viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TrackingViewModel on TrackingViewModelBase, Store {
  late final _$trackListAtom =
      Atom(name: 'TrackingViewModelBase.trackList', context: context);

  @override
  ObservableList<PlaceModel> get trackList {
    _$trackListAtom.reportRead();
    return super.trackList;
  }

  @override
  set trackList(ObservableList<PlaceModel> value) {
    _$trackListAtom.reportWrite(value, super.trackList, () {
      super.trackList = value;
    });
  }

  late final _$listRotasOnlineAtom =
      Atom(name: 'TrackingViewModelBase.listRotasOnline', context: context);

  @override
  List<PlaceModel> get listRotasOnline {
    _$listRotasOnlineAtom.reportRead();
    return super.listRotasOnline;
  }

  @override
  set listRotasOnline(List<PlaceModel> value) {
    _$listRotasOnlineAtom.reportWrite(value, super.listRotasOnline, () {
      super.listRotasOnline = value;
    });
  }

  late final _$listRotasLocalAtom =
      Atom(name: 'TrackingViewModelBase.listRotasLocal', context: context);

  @override
  List<PlaceModel> get listRotasLocal {
    _$listRotasLocalAtom.reportRead();
    return super.listRotasLocal;
  }

  @override
  set listRotasLocal(List<PlaceModel> value) {
    _$listRotasLocalAtom.reportWrite(value, super.listRotasLocal, () {
      super.listRotasLocal = value;
    });
  }

  late final _$loadingAtom =
      Atom(name: 'TrackingViewModelBase.loading', context: context);

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

  late final _$insertTrackingAsyncAction =
      AsyncAction('TrackingViewModelBase.insertTracking', context: context);

  @override
  Future<void> insertTracking(PlaceModel initialLocation) {
    return _$insertTrackingAsyncAction
        .run(() => super.insertTracking(initialLocation));
  }

  late final _$removeRotaAsyncAction =
      AsyncAction('TrackingViewModelBase.removeRota', context: context);

  @override
  Future<void> removeRota(int rotaId) {
    return _$removeRotaAsyncAction.run(() => super.removeRota(rotaId));
  }

  late final _$trackLocationAsyncAction =
      AsyncAction('TrackingViewModelBase.trackLocation', context: context);

  @override
  Future<void> trackLocation(PlaceModel location, String name) {
    return _$trackLocationAsyncAction
        .run(() => super.trackLocation(location, name));
  }

  late final _$stopTrackingAsyncAction =
      AsyncAction('TrackingViewModelBase.stopTracking', context: context);

  @override
  Future<void> stopTracking(PlaceModel finalLocation) {
    return _$stopTrackingAsyncAction
        .run(() => super.stopTracking(finalLocation));
  }

  late final _$syncRotaAsyncAction =
      AsyncAction('TrackingViewModelBase.syncRota', context: context);

  @override
  Future<bool> syncRota(PlaceModel rota) {
    return _$syncRotaAsyncAction.run(() => super.syncRota(rota));
  }

  late final _$getRotasOnlineAsyncAction =
      AsyncAction('TrackingViewModelBase.getRotasOnline', context: context);

  @override
  Future<dynamic> getRotasOnline() {
    return _$getRotasOnlineAsyncAction.run(() => super.getRotasOnline());
  }

  late final _$TrackingViewModelBaseActionController =
      ActionController(name: 'TrackingViewModelBase', context: context);

  @override
  dynamic changeLoading(bool value) {
    final _$actionInfo = _$TrackingViewModelBaseActionController.startAction(
        name: 'TrackingViewModelBase.changeLoading');
    try {
      return super.changeLoading(value);
    } finally {
      _$TrackingViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
trackList: ${trackList},
listRotasOnline: ${listRotasOnline},
listRotasLocal: ${listRotasLocal},
loading: ${loading}
    ''';
  }
}
