import 'package:flutter/material.dart';
import 'package:food_delivery/models/restaurant_model.dart';

class AllRestaurantsScreen extends StatelessWidget {
  final List<Restaurant> allRestaurants;

  const AllRestaurantsScreen({Key? key, required this.allRestaurants}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'All Restaurants',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: allRestaurants.map((restaurant) {
            return _buildRestaurantCard(
              restaurant.name,
              restaurant.categories,
              restaurant.imageUrl,
              restaurant.rating.toString(),
              restaurant.deliveryFee,
              restaurant.deliveryTime,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
      String name, String categories, String imageUrl, String rating, String deliveryFee, String deliveryTime) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C3F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  categories,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(rating, style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(width: 16),
                    Icon(Icons.delivery_dining, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(deliveryFee, style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(width: 16),
                    Icon(Icons.timer, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(deliveryTime, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
