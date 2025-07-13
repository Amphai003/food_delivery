import 'dart:convert';

class Address {
  final String id; // Unique ID for each address
  String addressLine1; // e.g., "2464 Royal Ln. Mesa"
  String? street;
  String? postCode;
  String? apartment;
  String label; // e.g., "Home", "Work", "Other"
  final double? latitude;
  final double? longitude;

  Address({
    required this.id,
    required this.addressLine1,
    this.street,
    this.postCode,
    this.apartment,
    this.label = 'Other', // Default label
    this.latitude,
    this.longitude,
  });

  // Factory constructor to create an Address from a JSON map
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      addressLine1: json['addressLine1'],
      street: json['street'],
      postCode: json['postCode'],
      apartment: json['apartment'],
      label: json['label'],
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  // Method to convert an Address object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'addressLine1': addressLine1,
      'street': street,
      'postCode': postCode,
      'apartment': apartment,
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}