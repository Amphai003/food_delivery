import 'package:flutter/material.dart';
import 'package:food_delivery/models/address_model.dart'; // Import the Address model
import 'package:uuid/uuid.dart'; // For generating unique IDs

class AddEditAddressScreen extends StatefulWidget {
  final Address? address; // Null if adding, non-null if editing

  const AddEditAddressScreen({Key? key, this.address}) : super(key: key);

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressLine1Controller = TextEditingController();
  final _streetController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _apartmentController = TextEditingController();
  String _selectedLabel = 'Other'; // Default label

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      // Populate fields if editing an existing address
      _addressLine1Controller.text = widget.address!.addressLine1;
      _streetController.text = widget.address!.street ?? '';
      _postCodeController.text = widget.address!.postCode ?? '';
      _apartmentController.text = widget.address!.apartment ?? '';
      _selectedLabel = widget.address!.label;
    }
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _streetController.dispose();
    _postCodeController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final String id = widget.address?.id ?? const Uuid().v4(); // Use existing ID or generate new
      final Address newAddress = Address(
        id: id,
        addressLine1: _addressLine1Controller.text,
        street: _streetController.text.isNotEmpty ? _streetController.text : null,
        postCode: _postCodeController.text.isNotEmpty ? _postCodeController.text : null,
        apartment: _apartmentController.text.isNotEmpty ? _apartmentController.text : null,
        label: _selectedLabel,
        // Latitude and longitude would typically come from a map picker
        latitude: widget.address?.latitude,
        longitude: widget.address?.longitude,
      );
      Navigator.pop(context, newAddress); // Return the new/updated address
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.address == null ? 'Add New Address' : 'Edit Address',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dummy Map Section (as per image)
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage('https://placehold.co/600x200/E0E0E0/000000?text=Map+View'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Move to edit location',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'ADDRESS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C3F),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressLine1Controller,
                decoration: InputDecoration(
                  labelText: 'Address Line 1 (e.g., 3235 Royal Ln. Mesa, New Jersy 34567)',
                  prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address line 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _streetController,
                      decoration: InputDecoration(
                        labelText: 'Street',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _postCodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Post Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apartmentController,
                decoration: InputDecoration(
                  labelText: 'Apartment / Suite / Unit (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'LABEL AS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C3F),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildLabelChip('Home'),
                  const SizedBox(width: 8),
                  _buildLabelChip('Work'),
                  const SizedBox(width: 8),
                  _buildLabelChip('Other'),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.address == null ? 'SAVE LOCATION' : 'UPDATE LOCATION',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelChip(String label) {
    final bool isSelected = _selectedLabel == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLabel = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}