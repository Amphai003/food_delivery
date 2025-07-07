import 'package:flutter/material.dart';
import 'package:food_delivery/widgets/custom_button.dart';
import 'package:food_delivery/screens/track_order_screen.dart'; // Import TrackOrderScreen
import 'package:shared_preferences/shared_preferences.dart'; // For saving last order
import 'package:food_delivery/models/cart_item_model.dart'; // For cart item model
import 'dart:convert'; // For jsonEncode

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({Key? key}) : super(key: key);

  Future<void> _trackOrder(BuildContext context) async {
    // In a real app, you would fetch the actual order ID and details from a backend.
    // Here, we'll just navigate to the TrackOrderScreen.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TrackOrderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image placeholder for the celebration illustration
            Image.network(
              'https://placehold.co/200x200/FF8C00/FFFFFF?text=🎉', // Placeholder for a celebration image
              height: 200,
              width: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.celebration, color: Colors.orange, size: 80),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            const Text(
              'Congratulations!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C3F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You successfully made a payment, enjoy our service!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: 'TRACK ORDER',
              onPressed: () => _trackOrder(context),
            ),
          ],
        ),
      ),
    );
  }
}
