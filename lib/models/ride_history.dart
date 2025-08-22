import 'package:cloud_firestore/cloud_firestore.dart';

class RideHistory {
  final String id;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String userId;
  final String username;
  final String userPhone;
  final Address origin;
  final String originAddress;
  final Address destination;
  final String destinationAddress;
  final String model;
  final String colour;
  final String numberPlate;
  final String status;
  final DateTime time;
  final double fare;

  RideHistory({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.userId,
    required this.username,
    required this.userPhone,
    required this.origin,
    required this.originAddress,
    required this.destination,
    required this.destinationAddress,
    required this.model,
    required this.colour,
    required this.numberPlate,
    required this.status,
    required this.time,
    required this.fare,
  });

  /// Convert Firestore doc to RideHistory
  factory RideHistory.fromFirestore(Map<String, dynamic> data, String docId) {
    return RideHistory(
      id: docId,
      driverId: data['driverId'] ?? '',
      driverName: data['driverName'] ?? '',
      driverPhone: data['driverPhone'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userPhone: data['userPhone'] ?? '',
      origin: Address.fromMap(data['origin'] ?? {}),
      originAddress: data['originAddress'] ?? '',
      destination: Address.fromMap(data['destination'] ?? {}),
      destinationAddress: data['destinationAddress'] ?? '',
      model: data['model'] ?? '',
      colour: data['colour'] ?? '',
      numberPlate: data['numberPlate'] ?? '',
      status: data['status'] ?? 'pending',
      time: data['time'] is Timestamp
          ? (data['time'] as Timestamp).toDate()
          : (data['time'] is DateTime
                ? data['time']
                : (data['time'] != null
                      ? DateTime.parse(data['time'].toString())
                      : DateTime.now())),
      fare: (data['fare'] ?? 0).toDouble(),
    );
  }

  factory RideHistory.fromRealtime(Map<String, dynamic> data, String docId) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return RideHistory(
      id: docId,
      driverId: data['driverId'] ?? '',
      driverName: data['driverName'] ?? '',
      driverPhone: data['driverPhone'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userPhone: data['userPhone'] ?? '',
      origin: Address.fromMap(Map<String, dynamic>.from(data['origin'] ?? {})),
      originAddress: data['originAddress'] ?? '',
      destination: Address.fromMap(
        Map<String, dynamic>.from(data['destination'] ?? {}),
      ),
      destinationAddress: data['destinationAddress'] ?? '',
      model: data['model'] ?? '',
      colour: data['colour'] ?? '',
      numberPlate: data['numberPlate'] ?? '',
      status: data['status'] ?? 'pending',
      time: parseDate(data['time']),
      // time: DateTime.fromMillisecondsSinceEpoch(data['time'] ?? 0),
      fare: (data['fare'] ?? 0).toDouble(),
    );
  }

  /// Convert RideHistory to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'userId': userId,
      'username': username,
      'userPhone': userPhone,
      'origin': origin.toMap(),
      'originAddress': originAddress,
      'destination': destination.toMap(),
      'destinationAddress': destinationAddress,
      'model': model,
      'colour': colour,
      'numberPlate': numberPlate,
      'status': status,
      'time': time,
      'fare': fare,
    };
  }
}

class Address {
  final double latitude;
  final double longitude;

  Address({required this.latitude, required this.longitude});

  factory Address.fromMap(Map<String, dynamic> data) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Address(
      latitude: parseDouble(data['latitude']),
      longitude: parseDouble(data['longitude']),
    );
  }

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}
