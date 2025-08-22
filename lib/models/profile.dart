import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String id;
  final String email;
  final String username;
  final String role;
  final String token;
  final Personal personal;
  final Vehicle vehicle;
  final Account account;
  final List rides;
  final List drives;

  Profile({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.token,
    required this.personal,
    required this.vehicle,
    required this.account,
    required this.rides,
    required this.drives,
  });

  factory Profile.fromMap(Map<String, dynamic> map, {required String id}) {
    return Profile(
      id: id,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? '',
      token: map['token'] ?? '',
      personal: Personal.fromMap(map['personal'] ?? {}),
      vehicle: Vehicle.fromMap(map['vehicle'] ?? {}),
      account: Account.fromMap(map['account'] ?? {}),
      rides: map['rides'] ?? [],
      drives: map['drives'] ?? [],
    );
  }

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Profile.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'token': token,
      'personal': personal.toMap(),
      'vehicle': vehicle.toMap(),
      'account': account.toMap(),
      'drives': drives,
      'rides': rides,
    };
  }

  /// ✅ copyWith
  Profile copyWith({
    String? id,
    String? email,
    String? username,
    String? role,
    String? token,
    Personal? personal,
    Vehicle? vehicle,
    Account? account,
    List? rides,
    List? drives,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
      personal: personal ?? this.personal,
      vehicle: vehicle ?? this.vehicle,
      account: account ?? this.account,
      rides: rides ?? this.rides,
      drives: drives ?? this.drives,
    );
  }
}

class Personal {
  final String firstName;
  final String lastName;
  final String photoUrl;
  final double rating;
  final String phone;

  Personal({
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
    required this.rating,
    required this.phone,
  });

  factory Personal.fromMap(Map<String, dynamic> map) {
    return Personal(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'rating': rating,
      'phone': phone,
    };
  }

  Personal copyWith({
    String? firstName,
    String? lastName,
    String? photoUrl,
    double? rating,
    String? phone,
  }) {
    return Personal(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      phone: phone ?? this.phone,
    );
  }
}

class Vehicle {
  final String numberPlate;
  final String colour;
  final String licence;
  final String model;
  final String carImage;

  Vehicle({
    required this.numberPlate,
    required this.colour,
    required this.licence,
    required this.model,
    required this.carImage,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      numberPlate: map['numberPlate'] ?? '',
      colour: map['colour'] ?? '',
      licence: map['licence'] ?? '',
      model: map['model'] ?? '',
      carImage: map['carImage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numberPlate': numberPlate,
      'colour': colour,
      'licence': licence,
      'model': model,
      'carImage': carImage,
    };
  }

  Vehicle copyWith({
    String? numberPlate,
    String? colour,
    String? licence,
    String? model,
    String? carImage,
  }) {
    return Vehicle(
      numberPlate: numberPlate ?? this.numberPlate,
      colour: colour ?? this.colour,
      licence: licence ?? this.licence,
      model: model ?? this.model,
      carImage: carImage ?? this.carImage,
    );
  }
}

class Account {
  final bool isOnline;
  final bool isProfileCompleted;
  final bool isApproved;
  final DateTime createdAt;

  Account({
    required this.isOnline,
    required this.isProfileCompleted,
    required this.isApproved,
    required this.createdAt,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      isOnline: map['isOnline'] ?? false,
      isProfileCompleted: map['isProfileCompleted'] ?? false,
      isApproved: map['isApproved'] ?? false,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] is String)
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isOnline': isOnline,
      'isProfileCompleted': isProfileCompleted,
      'isApproved': isApproved,
      'createdAt': createdAt,
    };
  }

  Account copyWith({
    bool? isOnline,
    bool? isProfileCompleted,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return Account(
      isOnline: isOnline ?? this.isOnline,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
