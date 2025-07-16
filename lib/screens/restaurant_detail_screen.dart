
import 'package:flutter/material.dart';
import 'package:food_delivery/models/restaurant_model.dart';
import 'package:food_delivery/models/food_model.dart'; 
import 'package:food_delivery/screens/food_details_screen.dart'; 

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;
  final List<Food> availableFoodItems; 

  const RestaurantDetailScreen({
    Key? key,
    required this.restaurant,
    required this.availableFoodItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter food items relevant to this restaurant (you'll need a way to link them)
    // For now, let's assume all food items are available through all restaurants
    // In a real app, food items would belong to specific restaurants.
    final List<Food> restaurantFood = availableFoodItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                restaurant.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              restaurant.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C3F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              restaurant.categories,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange, size: 20),
                const SizedBox(width: 4),
                Text(
                  restaurant.rating.toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(width: 16),
                Icon(Icons.delivery_dining, color: Colors.grey[600], size: 20),
                const SizedBox(width: 4),
                Text(
                  restaurant.deliveryFee,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer, color: Colors.grey[600], size: 20),
                const SizedBox(width: 4),
                Text(
                  restaurant.deliveryTime,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Menu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C3F),
              ),
            ),
            const SizedBox(height: 16),
            // Display food items from this restaurant
            restaurantFood.isEmpty
                ? const Center(child: Text('No food items available for this restaurant.'))
                : Column(
                    children: restaurantFood.map((food) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodDetailScreen(food: food),
                            ),
                          );
                        },
                        child: _buildFoodItemCard(food),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  // Re-use the _buildFoodItemCard widget from HomeScreen
  Widget _buildFoodItemCard(Food food) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Hero(
              tag: 'foodImage-${food.name}',
              child: Image.network(
                food.imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C3F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LAK ${food.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}