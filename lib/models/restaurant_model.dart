import 'dart:convert';

class Restaurant {
  final String name;
  final String categories; // e.g., "Burger - Chicken"
  final String imageUrl;
  final double rating;
  final String deliveryFee;
  final String deliveryTime;

  Restaurant({
    required this.name,
    required this.categories,
    required this.imageUrl,
    required this.rating,
    required this.deliveryFee,
    required this.deliveryTime,
  });

  // Factory constructor to create a Restaurant from a JSON map
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'],
      categories: json['categories'],
      imageUrl: json['imageUrl'],
      rating: json['rating'] as double,
      deliveryFee: json['deliveryFee'],
      deliveryTime: json['deliveryTime'],
    );
  }

  // Method to convert a Restaurant object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categories': categories,
      'imageUrl': imageUrl,
      'rating': rating,
      'deliveryFee': deliveryFee,
      'deliveryTime': deliveryTime,
    };
  }
}