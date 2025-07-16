import 'package:flutter/material.dart';
import 'package:food_delivery/screens/address_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:food_delivery/models/user_model.dart'; // Ensure this path is correct
import 'package:food_delivery/screens/personal_edit_screen.dart'; // Import the new screen
import 'package:food_delivery/screens/cart_screen.dart'; // Import CartScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  // Function to refresh user data after returning from PersonalEditScreen
  void _refreshUserData() {
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background color for the screen
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.orange.shade100,
                    backgroundImage: _currentUser?.profileImageUrl != null && _currentUser!.profileImageUrl!.isNotEmpty
                        ? NetworkImage(_currentUser!.profileImageUrl!)
                        : null,
                    child: _currentUser?.profileImageUrl == null || _currentUser!.profileImageUrl!.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.orange)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUser?.name ?? 'Guest User',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C3F),
                        ),
                      ),
                      Text(
                        _currentUser?.tagline ?? 'I love food', // Assuming a tagline in User model
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Personal Info & Addresses Section
            _buildSectionCard([
              _buildProfileListItem(
                icon: Icons.person_outline,
                title: 'Personal Info',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalEditScreen(currentUser: _currentUser),
                    ),
                  );
                  _refreshUserData(); // Refresh user data after returning
                },
              ),
              _buildProfileListItem(
                icon: Icons.map_outlined,
                title: 'Addresses',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddressScreen()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Cart Section
            _buildSectionCard([
              _buildProfileListItem(
                icon: Icons.shopping_bag_outlined,
                title: 'Cart',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Settings Section
            // _buildSectionCard([
            //   _buildProfileListItem(
            //     icon: Icons.settings_outlined,
            //     title: 'Settings',
            //     onTap: () {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('Settings tapped!')),
            //       );
            //       // TODO: Navigate to Settings screen
            //     },
            //   ),
            // ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
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
        children: children.map((item) {
          // Add a divider between items, but not after the last one
          if (item != children.last) {
            return Column(
              children: [item, Divider(indent: 16, endIndent: 16, height: 1)],
            );
          }
          return item;
        }).toList(),
      ),
    );
  }

  Widget _buildProfileListItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.orange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2C2C3F),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}