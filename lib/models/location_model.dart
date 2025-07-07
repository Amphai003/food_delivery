import 'dart:convert';

class Location {
  final String address;
  final double? latitude;
  final double? longitude;

  Location({
    required this.address,
    this.latitude,
    this.longitude,
  });

  // Factory constructor to create a Location from a JSON map
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'],
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  // Method to convert a Location object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
