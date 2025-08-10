class Profile {
  String id;
  String firstName;
  String lastName;
  String displayName;
  String role;
  String phone;
  bool isOnline;
  String model;
  String number;
  double rating;
  String colour;

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.role,
    required this.phone,
    required this.isOnline,
    required this.model,
    required this.number,
    required this.rating,
    required this.colour,
  });
  // MAP TO PROFILE
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      displayName: map['display_name'] as String,
      role: map['role'] as String,
      phone: map['phone'] ?? '',
      isOnline: map['is_online'] as bool,
      model: map['model'] ?? '',
      number: map['number'] ?? '',
      rating: map['rating'] * 1.0 as double,
      colour: map['colour'] ?? '',
    );
  }

  // PROFILE TO MAP
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'display_name': displayName,
      'role': role,
      'phone': phone,
      'is_online': isOnline,
      'model': model,
      'number': number,
      'rating': rating,
      'colour': colour,
    };
  }
}
