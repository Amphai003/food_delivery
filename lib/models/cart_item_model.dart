import 'dart:convert';

class CartItem {
  final String foodId; // Unique identifier for the food item
  final String name;
  final double price;
  final String imageUrl;
  int quantity;
  String? status; // Added: Field to store the order status (e.g., 'Ongoing', 'Completed', 'Cancelled')

  CartItem({
    required this.foodId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.status, // Added: Initialize status in constructor
  });

  // Factory constructor to create a CartItem from a JSON map
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      foodId: json['foodId'],
      name: json['name'],
      price: json['price'] as double,
      imageUrl: json['imageUrl'],
      quantity: json['quantity'] as int,
      status: json['status'], // Added: Deserialize status
    );
  }

  // Method to convert a CartItem object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'status': status, // Added: Serialize status
    };
  }

  // Added: copyWith method for easily creating a new CartItem with updated values
  CartItem copyWith({
    String? foodId,
    String? name,
    double? price,
    String? imageUrl,
    int? quantity,
    String? status, // Allow updating status
  }) {
    return CartItem(
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status, // Copy or update status
    );
  }
}