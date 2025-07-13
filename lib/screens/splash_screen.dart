import 'package:flutter/material.dart';
import 'dart:async';
import 'package:food_delivery/screens/login_screen.dart'; // Make sure this path is correct
import '../widgets/food_logo.dart'; // Make sure this path is correct
import '../widgets/rays_painter.dart'; // Make sure this path is correct

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Keep a reference to the timer so you can cancel it
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2), // Use const for Duration
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();

    // Start the timer and store its reference
    _timer = Timer(const Duration(seconds: 3), () {
      _navigateToLogin();
    });
  }

  void _navigateToLogin() {
    // Crucial check: only navigate if the widget is still mounted
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()), // Add const
      );
    }
  }

  @override
  void dispose() {
    // Cancel the timer to prevent it from trying to navigate after dispose
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _navigateToLogin,
        child: SizedBox( // Changed from Container to SizedBox as it's primarily for sizing
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Decorative rays in bottom right
              Positioned(
                bottom: -50,
                right: -50,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animationController.value * 0.5,
                      child: CustomPaint(
                        size: const Size(200, 200), // Add const
                        painter: RaysPainter(),
                      ),
                    );
                  },
                ),
              ),

              // Main content
              Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Food logo
                            const FoodLogo(fontSize: 48), // Add const
                            const SizedBox(height: 20), // Add const
                            Text(
                              'Delicious Food Awaits',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 40), // Add const
                            // Loading indicator
                            const SizedBox( // Add const
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Tap to continue hint
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Tap anywhere to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}