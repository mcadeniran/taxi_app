import 'package:taxi_app/models/active_nearby_available_driver.dart';

class GeofireAssistant {
  static List<ActiveNearbyAvailableDriver> activeNearbyAvailableDriversList =
      [];

  static void deleteOfflineDriverFromList(String driverId) {
    int indexNumber = activeNearbyAvailableDriversList.indexWhere(
      (element) => element.driverId == driverId,
    );

    activeNearbyAvailableDriversList.removeAt(indexNumber);
  }

  static void updateActiveNearbyAvailableDriverLocation(
    ActiveNearbyAvailableDriver driverWhoMoves,
  ) {
    int indexNumber = activeNearbyAvailableDriversList.indexWhere(
      (element) => element.driverId == driverWhoMoves.driverId,
    );

    activeNearbyAvailableDriversList[indexNumber].locationLatitude =
        driverWhoMoves.locationLatitude;

    activeNearbyAvailableDriversList[indexNumber].locationLongitude =
        driverWhoMoves.locationLongitude;
  }
}
