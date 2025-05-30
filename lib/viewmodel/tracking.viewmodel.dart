import 'package:mobx/mobx.dart';
import 'package:track_tcc_app/model/place.model.dart';
import 'package:track_tcc_app/repository/track.repository.dart';

part 'tracking.viewmodel.g.dart';

class TrackingViewModel = TrackingViewModelBase with _$TrackingViewModel;

abstract class TrackingViewModelBase with Store {
  final TrackRepository trackRepository = TrackRepository();

  int? currentRotaId;

  @observable
  ObservableList<PlaceModel> trackList = ObservableList<PlaceModel>();

  @action
  Future<void> insertTracking(PlaceModel initialLocation) async {
    final rotaId = await trackRepository.insertRota(initialLocation);
    currentRotaId = rotaId;
    trackList.clear();
    trackList.insert(0, initialLocation);
  }

  @action
  Future<void> trackLocation(PlaceModel location) async {
    if (currentRotaId != null) {
      trackList.insert(0, location);
      await trackRepository.insertRotaPoint(currentRotaId!, location);
    }
  }

  @action
  Future<void> stopTracking(PlaceModel finalLocation) async {
    if (currentRotaId != null) {
      await trackRepository.updateRotaFinal(currentRotaId!, finalLocation);
      currentRotaId = null;
    }
  }

  Future<List<PlaceModel>> getAllRotas() async {
    return await trackRepository.getAllRotas();
  }

  Future<List<PlaceModel>> getPontosByRota(int rotaId) async {
    return await trackRepository.getPontosByRotaId(rotaId);
  }
}
