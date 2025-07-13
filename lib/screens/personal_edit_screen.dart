import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:food_delivery/models/user_model.dart'; // Ensure this path is correct

class PersonalEditScreen extends StatefulWidget {
  final User? currentUser;

  const PersonalEditScreen({Key? key, this.currentUser}) : super(key: key);

  @override
  State<PersonalEditScreen> createState() => _PersonalEditScreenState();
}

class _PersonalEditScreenState extends State<PersonalEditScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _taglineController = TextEditingController(); // For the "I love fast food" text
  final _profileImageUrlController = TextEditingController(); // For profile image URL

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null) {
      _nameController.text = widget.currentUser!.name;
      _emailController.text = widget.currentUser!.email;
      _taglineController.text = widget.currentUser!.tagline ?? '';
      _profileImageUrlController.text = widget.currentUser!.profileImageUrl ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _taglineController.dispose();
    _profileImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _savePersonalInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final updatedUser = User(
      name: _nameController.text,
      email: _emailController.text,
      tagline: _taglineController.text.isNotEmpty ? _taglineController.text : null,
      profileImageUrl: _profileImageUrlController.text.isNotEmpty ? _profileImageUrlController.text : null,
    );
    await prefs.setString('registeredUser', jsonEncode(updatedUser.toJson()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal info saved!')),
    );
    Navigator.pop(context); // Go back to ProfileScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Edit Personal Info',
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
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.orange.shade100,
                    backgroundImage: _profileImageUrlController.text.isNotEmpty
                        ? NetworkImage(_profileImageUrlController.text)
                        : null,
                    child: _profileImageUrlController.text.isEmpty
                        ? const Icon(Icons.person, size: 70, color: Colors.orange)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement image picking logic (e.g., from gallery/camera)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Change profile picture tapped!')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _nameController,
              labelText: 'Full Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              labelText: 'Email Address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _taglineController,
              labelText: 'Tagline (e.g., "I love fast food")',
              icon: Icons.notes,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _profileImageUrlController,
              labelText: 'Profile Image URL (Optional)',
              icon: Icons.image,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePersonalInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}