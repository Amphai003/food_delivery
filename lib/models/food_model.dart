import 'dart:convert';

class Food {
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  final String description;

  Food({
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    this.description = '',
  });

  // Factory constructor to create a Food from a JSON map
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      name: json['name'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      price: json['price'] as double,
      description: json['description'] ?? '',
    );
  }

  // Method to convert a Food object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
    };
  }
}
