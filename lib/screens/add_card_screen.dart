import 'package:flutter/material.dart';
import 'package:food_delivery/widgets/custom_button.dart';
import 'package:food_delivery/widgets/custom_text_field.dart'; // Assuming CustomTextField is available

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _cardHolderNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expireDateController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cardHolderNameController.dispose();
    _cardNumberController.dispose();
    _expireDateController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  void _addAndMakePayment() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adding card and making payment...')),
      );
      // In a real app, you would integrate with a payment gateway here.
      // For demo, we'll just pop the screen.
      Navigator.of(context).pop(); // Go back to PaymentScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Add Card',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _cardHolderNameController,
                label: 'CARD HOLDER NAME',
                hintText: 'Vishal Khadok',
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _cardNumberController,
                label: 'CARD NUMBER',
                hintText: '2134 L _ _ _ _ _ _ _ _', // Placeholder for card number
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  if (value.length < 16) { // Basic validation
                    return 'Card number must be 16 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _expireDateController,
                      label: 'EXPIRE DATE',
                      hintText: 'mm/yyyy',
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expiry date';
                        }
                        // Basic format validation (e.g., MM/YY or MM/YYYY)
                        if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{4}|[0-9]{2})$').hasMatch(value)) {
                          return 'Invalid date format (MM/YYYY)';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: CustomTextField(
                      controller: _cvcController,
                      label: 'CVC',
                      hintText: '•••',
                      keyboardType: TextInputType.number,
                      isPassword: true, // To hide CVC
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CVC';
                        }
                        if (value.length < 3 || value.length > 4) { // CVC is usually 3 or 4 digits
                          return 'Invalid CVC';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: 'ADD & MAKE PAYMENT',
                onPressed: _addAndMakePayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
