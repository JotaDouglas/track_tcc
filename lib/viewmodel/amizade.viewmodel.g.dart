// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'amizade.viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AmizadeViewModel on AmizadeViewModelBase, Store {
  late final _$friendsAtom =
      Atom(name: 'AmizadeViewModelBase.friends', context: context);

  @override
  List<Map<String, dynamic>> get friends {
    _$friendsAtom.reportRead();
    return super.friends;
  }

  @override
  set friends(List<Map<String, dynamic>> value) {
    _$friendsAtom.reportWrite(value, super.friends, () {
      super.friends = value;
    });
  }

  late final _$requestsAtom =
      Atom(name: 'AmizadeViewModelBase.requests', context: context);

  @override
  List<Map<String, dynamic>> get requests {
    _$requestsAtom.reportRead();
    return super.requests;
  }

  @override
  set requests(List<Map<String, dynamic>> value) {
    _$requestsAtom.reportWrite(value, super.requests, () {
      super.requests = value;
    });
  }

  late final _$changeFriendsAsyncAction =
      AsyncAction('AmizadeViewModelBase.changeFriends', context: context);

  @override
  Future changeFriends(List<Map<String, dynamic>> f) {
    return _$changeFriendsAsyncAction.run(() => super.changeFriends(f));
  }

  late final _$changeRequestsAsyncAction =
      AsyncAction('AmizadeViewModelBase.changeRequests', context: context);

  @override
  Future changeRequests(List<Map<String, dynamic>> r) {
    return _$changeRequestsAsyncAction.run(() => super.changeRequests(r));
  }

  late final _$readMyFriendsAsyncAction =
      AsyncAction('AmizadeViewModelBase.readMyFriends', context: context);

  @override
  Future readMyFriends({bool onlyFriends = false, bool solicitations = false}) {
    return _$readMyFriendsAsyncAction.run(() => super
        .readMyFriends(onlyFriends: onlyFriends, solicitations: solicitations));
  }

  @override
  String toString() {
    return '''
friends: ${friends},
requests: ${requests}
    ''';
  }
}
