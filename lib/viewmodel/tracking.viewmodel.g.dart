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

  late final _$trackingLoopAtom =
      Atom(name: 'TrackingViewModelBase.trackingLoop', context: context);

  @override
  bool get trackingLoop {
    _$trackingLoopAtom.reportRead();
    return super.trackingLoop;
  }

  @override
  set trackingLoop(bool value) {
    _$trackingLoopAtom.reportWrite(value, super.trackingLoop, () {
      super.trackingLoop = value;
    });
  }

  late final _$trackingModeAtom =
      Atom(name: 'TrackingViewModelBase.trackingMode', context: context);

  @override
  bool get trackingMode {
    _$trackingModeAtom.reportRead();
    return super.trackingMode;
  }

  @override
  set trackingMode(bool value) {
    _$trackingModeAtom.reportWrite(value, super.trackingMode, () {
      super.trackingMode = value;
    });
  }

  late final _$distanceMetersAtom =
      Atom(name: 'TrackingViewModelBase.distanceMeters', context: context);

  @override
  double get distanceMeters {
    _$distanceMetersAtom.reportRead();
    return super.distanceMeters;
  }

  @override
  set distanceMeters(double value) {
    _$distanceMetersAtom.reportWrite(value, super.distanceMeters, () {
      super.distanceMeters = value;
    });
  }

  late final _$lastPlaceAtom =
      Atom(name: 'TrackingViewModelBase.lastPlace', context: context);

  @override
  PlaceModel? get lastPlace {
    _$lastPlaceAtom.reportRead();
    return super.lastPlace;
  }

  @override
  set lastPlace(PlaceModel? value) {
    _$lastPlaceAtom.reportWrite(value, super.lastPlace, () {
      super.lastPlace = value;
    });
  }

  late final _$lastPositionAtom =
      Atom(name: 'TrackingViewModelBase.lastPosition', context: context);

  @override
  LatLng? get lastPosition {
    _$lastPositionAtom.reportRead();
    return super.lastPosition;
  }

  @override
  set lastPosition(LatLng? value) {
    _$lastPositionAtom.reportWrite(value, super.lastPosition, () {
      super.lastPosition = value;
    });
  }

  late final _$addressLabelAtom =
      Atom(name: 'TrackingViewModelBase.addressLabel', context: context);

  @override
  String get addressLabel {
    _$addressLabelAtom.reportRead();
    return super.addressLabel;
  }

  @override
  set addressLabel(String value) {
    _$addressLabelAtom.reportWrite(value, super.addressLabel, () {
      super.addressLabel = value;
    });
  }

  late final _$trackListLoopAtom =
      Atom(name: 'TrackingViewModelBase.trackListLoop', context: context);

  @override
  List<PlaceModel> get trackListLoop {
    _$trackListLoopAtom.reportRead();
    return super.trackListLoop;
  }

  @override
  set trackListLoop(List<PlaceModel> value) {
    _$trackListLoopAtom.reportWrite(value, super.trackListLoop, () {
      super.trackListLoop = value;
    });
  }

  late final _$tempAtom =
      Atom(name: 'TrackingViewModelBase.temp', context: context);

  @override
  Timer? get temp {
    _$tempAtom.reportRead();
    return super.temp;
  }

  @override
  set temp(Timer? value) {
    _$tempAtom.reportWrite(value, super.temp, () {
      super.temp = value;
    });
  }

  late final _$trackingIntervalAtom =
      Atom(name: 'TrackingViewModelBase.trackingInterval', context: context);

  @override
  int get trackingInterval {
    _$trackingIntervalAtom.reportRead();
    return super.trackingInterval;
  }

  @override
  set trackingInterval(int value) {
    _$trackingIntervalAtom.reportWrite(value, super.trackingInterval, () {
      super.trackingInterval = value;
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

  late final _$startTrackingAsyncAction =
      AsyncAction('TrackingViewModelBase.startTracking', context: context);

  @override
  Future<void> startTracking(String userName) {
    return _$startTrackingAsyncAction.run(() => super.startTracking(userName));
  }

  late final _$_trackOnceAsyncAction =
      AsyncAction('TrackingViewModelBase._trackOnce', context: context);

  @override
  Future<void> _trackOnce(String userName) {
    return _$_trackOnceAsyncAction.run(() => super._trackOnce(userName));
  }

  late final _$TrackingViewModelBaseActionController =
      ActionController(name: 'TrackingViewModelBase', context: context);

  @override
  void setTrackingInterval(int seconds) {
    final _$actionInfo = _$TrackingViewModelBaseActionController.startAction(
        name: 'TrackingViewModelBase.setTrackingInterval');
    try {
      return super.setTrackingInterval(seconds);
    } finally {
      _$TrackingViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changeDistance(double value, {bool reset = false}) {
    final _$actionInfo = _$TrackingViewModelBaseActionController.startAction(
        name: 'TrackingViewModelBase.changeDistance');
    try {
      return super.changeDistance(value, reset: reset);
    } finally {
      _$TrackingViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

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
loading: ${loading},
trackingLoop: ${trackingLoop},
trackingMode: ${trackingMode},
distanceMeters: ${distanceMeters},
lastPlace: ${lastPlace},
lastPosition: ${lastPosition},
addressLabel: ${addressLabel},
trackListLoop: ${trackListLoop},
temp: ${temp},
trackingInterval: ${trackingInterval}
    ''';
  }
}
