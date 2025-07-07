import 'package:flutter/material.dart';
import 'package:food_delivery/screens/congratulation_screen.dart';
import 'package:food_delivery/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For clearing cart
import 'package:food_delivery/models/cart_item_model.dart'; // For refreshing cart count
import 'package:food_delivery/screens/add_card_screen.dart'; // Import AddCardScreen

import 'dart:convert'; // For jsonEncode

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({Key? key, required this.totalAmount}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'Mastercard'; // Default selected method

  // Map payment method names to their image URLs
  final Map<String, String> _paymentMethodImages = {
    'Cash': 'https://img.icons8.com/ios-filled/50/000000/money.png', // Placeholder for Cash icon
    'Visa': 'https://img.icons8.com/ios-filled/50/000000/visa.png', // Placeholder for Visa icon
    'Mastercard': 'https://img.icons8.com/ios-filled/50/000000/mastercard.png', // Placeholder for Mastercard icon
    'PayPal': 'https://img.icons8.com/ios-filled/50/000000/paypal.png', // Placeholder for PayPal icon
  };

  Future<void> _payAndConfirm() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Processing payment with $_selectedPaymentMethod...')),
    );

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    
    // Get current cart items before clearing
    List<String> cartJsonList = prefs.getStringList('cartItems') ?? [];
    print('PaymentScreen: Cart items before saving to lastOrderItems: $cartJsonList');
    
    // Save current cart items as 'lastOrderItems' for tracking screen
    await prefs.setStringList('lastOrderItems', cartJsonList);
    print('PaymentScreen: Saved to lastOrderItems: ${prefs.getStringList('lastOrderItems')}');

    // Clear the cart after successful payment
    await prefs.remove('cartItems');
    print('PaymentScreen: Cart cleared.');

    // Navigate to the Congratulations Screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CongratulationsScreen()),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  Widget _buildPaymentMethodChip(String method, String imageUrl, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imageUrl,
              height: 30,
              width: 30,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.payment, color: Colors.grey, size: 30); // Fallback icon
              },
            ),
            const SizedBox(height: 8),
            Text(
              method,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.orange : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Payment',
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
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C3F),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPaymentMethodChip(
                  'Cash',
                  _paymentMethodImages['Cash']!,
                  isSelected: _selectedPaymentMethod == 'Cash',
                ),
                _buildPaymentMethodChip(
                  'Visa',
                  _paymentMethodImages['Visa']!,
                  isSelected: _selectedPaymentMethod == 'Visa',
                ),
                _buildPaymentMethodChip(
                  'Mastercard',
                  _paymentMethodImages['Mastercard']!,
                  isSelected: _selectedPaymentMethod == 'Mastercard',
                ),
                _buildPaymentMethodChip(
                  'PayPal',
                  _paymentMethodImages['PayPal']!,
                  isSelected: _selectedPaymentMethod == 'PayPal',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Image.network(
                    'https://placehold.co/200x120/FF8C00/FFFFFF?text=Card+Image', // Placeholder for card image
                    height: 120,
                    width: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.credit_card, color: Colors.grey, size: 60),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No $_selectedPaymentMethod added',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You can add a $_selectedPaymentMethod and save it for later',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to AddCardScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddCardScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'ADD NEW',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C3F),
                  ),
                ),
                Text(
                  'LAK ${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C3F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'PAY & CONFIRM',
              onPressed: _payAndConfirm,
            ),
          ],
        ),
      ),
    );
  }
}
