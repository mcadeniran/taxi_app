import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/ride_history.dart';

class RideHistoryProvider with ChangeNotifier {
  final DatabaseReference _ridesRef = FirebaseDatabase.instance.ref(
    "All Ride Requests",
  );

  List<RideHistory> _userRides = [];
  List<RideHistory> get userRides => _userRides;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Fetch rides for a specific userId
  Future<void> fetchUserRides(String userId) async {
    _isLoading = true;
    notifyListeners();

    _ridesRef.orderByChild("userId").equalTo(userId).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        _userRides = data.entries.map((entry) {
          final rideData = Map<String, dynamic>.from(entry.value);
          return RideHistory.fromRealtime(rideData, entry.key);
        }).toList();
      } else {
        _userRides = [];
      }

      _isLoading = false;
      notifyListeners();
    });
  }
}
