import 'package:flutter/material.dart';
import 'package:taxi_app/models/direction.dart';

class AppInfo extends ChangeNotifier {
  Direction? userPickUpLocation;
  Direction? userDropOffLocation;
  int countTotalTrips = 0;
  // List<String> historyTripsKeys = [];
  // List<TripsHistoryModel> allTripsHistoryInformationList = [];

  void updatePickUpLocationAddress(Direction userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Direction userDropOffAddress) {
    userDropOffLocation = userDropOffAddress;
    notifyListeners();
  }
}
