import 'dart:convert';

class User {
  final String email;
  final String name;
  // You can add more fields as needed, e.g., userId, token, etc.

  User({
    required this.email,
    required this.name,
  });

  // Factory constructor to create a User from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      name: json['name'],
    );
  }

  // Method to convert a User object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
    };
  }
}