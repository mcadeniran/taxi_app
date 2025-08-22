import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/ride_history.dart';

class DriveHistoryProvider with ChangeNotifier {
  final DatabaseReference _ridesRef = FirebaseDatabase.instance.ref(
    "All Ride Requests",
  );

  List<RideHistory> _driverRides = [];
  List<RideHistory> get driverRides => _driverRides;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Fetch rides for a specific driverId
  Future<void> fetchDriverRides(String driverId) async {
    _isLoading = true;
    notifyListeners();

    _ridesRef.orderByChild("driverId").equalTo(driverId).onValue.listen((
      event,
    ) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        _driverRides = data.entries.map((entry) {
          final rideData = Map<String, dynamic>.from(entry.value);
          return RideHistory.fromRealtime(rideData, entry.key);
        }).toList();
      } else {
        _driverRides = [];
      }

      _isLoading = false;
      notifyListeners();
    });
  }
}
