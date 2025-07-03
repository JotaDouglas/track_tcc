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

  late final _$insertTrackingAsyncAction =
      AsyncAction('TrackingViewModelBase.insertTracking', context: context);

  @override
  Future<void> insertTracking(PlaceModel initialLocation) {
    return _$insertTrackingAsyncAction
        .run(() => super.insertTracking(initialLocation));
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

  @override
  String toString() {
    return '''
trackList: ${trackList}
    ''';
  }
}
