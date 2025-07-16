import 'package:flutter/material.dart';
import 'package:food_delivery/screens/add_card_screen.dart'; 
import 'package:food_delivery/screens/my_orders_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:food_delivery/models/user_model.dart'; 
import 'package:food_delivery/screens/profile_screen.dart'; 
import 'package:food_delivery/screens/login_screen.dart'; 

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('registeredUser');
    setState(() {
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
      }
    });
  }

  // Method to show a loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must not dismiss it
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 16),
              Text(
                "Logging out...",
                style: TextStyle(color: Color(0xFF2C2C3F)),
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to perform the logout logic
  Future<void> _performLogout() async {
    _showLoadingDialog(context); // Show loading dialog

    // Simulate network delay or complex logout process
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    // IMPORTANT: Uncomment and keep these lines to clear all user-related data
    // await prefs.remove('registeredUser');
    // await prefs.remove('userLocation');
    // await prefs.remove('cartItems');
    // await prefs.remove('lastOrderItems');
    // await prefs.remove('orderHistory');
    // Also clear 'rememberedEmail' and 'rememberMe' on logout
    await prefs.remove('rememberedEmail');
    await prefs.remove('rememberMe');

    if (mounted) {
      // Check if the widget is still in the tree before navigating
      Navigator.of(context).pop(); // Dismiss the loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged out successfully!')));

      // Navigate to the LoginScreen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ), // Navigating to YOUR LoginScreen
        (Route<dynamic> route) => false,
      );
    }
  }

  // Method to show the logout confirmation dialog
  Future<void> _showLogoutConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // User chose No
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // User chose Yes
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _performLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.orange),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      _currentUser?.profileImageUrl != null &&
                              _currentUser!.profileImageUrl!.isNotEmpty
                          ? NetworkImage(_currentUser!.profileImageUrl!)
                          : null,
                  child:
                      _currentUser?.profileImageUrl == null ||
                              _currentUser!.profileImageUrl!.isEmpty
                          ? const Icon(Icons.person, size: 40, color: Colors.orange)
                          : null,
                ),
                const SizedBox(height: 10),
                Text(
                  _currentUser?.name ?? 'Guest User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currentUser?.email ?? 'guest@example.com',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.payment),
          //   title: const Text('Payment Methods'),
          //   onTap: () {
          //     Navigator.pop(context); // Close the drawer
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Payment Methods tapped!')),
          //     );
          //     // TODO: Navigate to Payment Methods Screen
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.history),
          //   title: const Text('Order History'),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const AddCardScreen()),
          //     );
          //     // TODO: Navigate to Order History Screen
          //   },
          // ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap:
                _showLogoutConfirmationDialog, // Call the confirmation dialog
          ),
        ],
      ),
    );
  }
}