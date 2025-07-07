import 'dart:convert';

class CartItem {
  final String foodId; // Unique identifier for the food item
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.foodId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  // Factory constructor to create a CartItem from a JSON map
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      foodId: json['foodId'],
      name: json['name'],
      price: json['price'] as double,
      imageUrl: json['imageUrl'],
      quantity: json['quantity'] as int,
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
    };
  }
}