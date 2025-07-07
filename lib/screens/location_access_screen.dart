import 'package:flutter/material.dart';
import 'package:food_delivery/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_delivery/models/location_model.dart'; // Import the Location model
import 'dart:convert'; // For jsonEncode

// Placeholder for your Home Screen
import 'package:food_delivery/screens/home_screen.dart'; // Assuming you'll create this

class LocationAccessScreen extends StatefulWidget {
  const LocationAccessScreen({Key? key}) : super(key: key);

  @override
  State<LocationAccessScreen> createState() => _LocationAccessScreenState();
}

class _LocationAccessScreenState extends State<LocationAccessScreen> {
  Future<void> _accessLocation() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Accessing your location...')),
    );

    // Simulate location access and saving
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, you would use a location package (e.g., geolocator)
    // to get the actual location and convert it to an address.
    // For now, we'll use a dummy address.
    final dummyLocation = Location(
      address: 'Halal Lab office', // From your home screen image
      latitude: 34.052235, // Example latitude
      longitude: -118.243683, // Example longitude
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userLocation', jsonEncode(dummyLocation.toJson()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location saved! Navigating to Home...')),
    );

    // Navigate to the Home Screen after location is managed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
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
          children: [
            // Image placeholder for the map and pin
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100], // Light grey background for the circle
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Simple map lines (placeholder)
                  Positioned(
                    top: 50,
                    left: 20,
                    child: Container(width: 80, height: 5, color: Colors.yellow[300]),
                  ),
                  Positioned(
                    top: 80,
                    right: 30,
                    child: Container(width: 60, height: 5, color: Colors.yellow[300]),
                  ),
                  Positioned(
                    bottom: 70,
                    left: 40,
                    child: Container(width: 70, height: 5, color: Colors.yellow[300]),
                  ),
                  Positioned(
                    top: 30,
                    right: 60,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Location Pin Icon
                  Icon(
                    Icons.location_on,
                    color: Colors.orange,
                    size: 80,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Access Location',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C3F),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'DFOOD WILL ACCESS YOUR LOCATION\nONLY WHILE USING THE APP',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: 'ACCESS LOCATION',
              onPressed: _accessLocation,
              // You might want to add a location icon to the button as well
              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: const [
              //     Icon(Icons.location_on, color: Colors.white),
              //     SizedBox(width: 8),
              //     Text('ACCESS LOCATION'),
              //   ],
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
