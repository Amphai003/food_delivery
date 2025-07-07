import 'package:flutter/material.dart';
import 'package:food_delivery/widgets/custom_button.dart';
import 'package:food_delivery/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:food_delivery/models/user_model.dart'; // Import the User model
import 'dart:convert'; // For jsonEncode

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isRetypePasswordVisible = false;
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleRetypePasswordVisibility() {
    setState(() {
      _isRetypePasswordVisible = !_isRetypePasswordVisible;
    });
  }

  Future<void> _onSignUpPressed() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signing up...')),
      );

      // In a real app, you would send this data to your backend
      // and only save locally upon successful backend registration.
      // For this example, we'll simulate success and save locally.
      final newUser = User(
        name: _nameController.text,
        email: _emailController.text,
        // In a real app, you would not store the plain password.
        // This is just for local simulation.
      );

      final prefs = await SharedPreferences.getInstance();
      // Save the user object as a JSON string
      await prefs.setString('registeredUser', jsonEncode(newUser.toJson()));
      // Also save the password for local login simulation
      await prefs.setString('registeredPassword', _passwordController.text);

      print('Registered User: ${newUser.toJson()}');
      print('Registered Password: ${_passwordController.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign Up Successful! You can now log in.')),
      );

      // Navigate back to the login screen after successful sign-up
      // Add a small delay to show the snackbar before popping
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top section with background and text
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35, // Adjust height as needed
              decoration: const BoxDecoration(
                color: Color(0xFF2C2C3F), // Dark background color from image
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                // You can add an image or pattern here if needed, similar to the background pattern in the image
              ),
              child: Stack(
                children: [
                  // This is a placeholder for the pattern seen in the image.
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // Go back to the previous screen (LoginScreen)
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please sign up to get started',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24), // Space after the top dark section
                    CustomTextField(
                      controller: _nameController,
                      label: 'NAME',
                      hintText: 'john doe',
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailController,
                      label: 'EMAIL',
                      hintText: 'example@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'PASSWORD',
                      hintText: '••••••••',
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      onTogglePassword: _togglePasswordVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _retypePasswordController,
                      label: 'RE-TYPE PASSWORD',
                      hintText: '••••••••',
                      isPassword: true,
                      isPasswordVisible: _isRetypePasswordVisible,
                      onTogglePassword: _toggleRetypePasswordVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please re-type your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'SIGN UP',
                      onPressed: _onSignUpPressed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}