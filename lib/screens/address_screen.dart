import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:food_delivery/models/address_model.dart';
import 'package:food_delivery/screens/add_edit_address_screen.dart';
import 'package:food_delivery/models/location_model.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Address> _addresses = [];
  String? _selectedAddressId; // To keep track of the currently selected address for delivery

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    // Call _loadSelectedLocation after _loadAddresses has completed
    _loadAddresses().then((_) => _loadSelectedLocation());
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> addressesJson = prefs.getStringList('savedAddresses') ?? [];
    setState(() {
      _addresses = addressesJson
          .map((jsonString) => Address.fromJson(jsonDecode(jsonString)))
          .toList();
    });
  }

  Future<void> _loadSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationJson = prefs.getString('userLocation');
    if (locationJson != null) {
      final Location currentLoc = Location.fromJson(jsonDecode(locationJson));
      // Find the ID of the current location if its address matches a saved address
      final matchedAddress = _addresses.firstWhere(
            (addr) => addr.addressLine1 == currentLoc.address,
        orElse: () => Address(id: '', addressLine1: ''), // Provide a dummy if not found
      );

      // Only set _selectedAddressId if a matching address was actually found (i.e., not the dummy)
      if (matchedAddress.id.isNotEmpty) {
        setState(() {
          _selectedAddressId = matchedAddress.id;
        });
      }
    } else {
      // If no userLocation is saved, ensure _selectedAddressId is null
      setState(() {
        _selectedAddressId = null;
      });
    }
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> addressesJson =
        _addresses.map((address) => jsonEncode(address.toJson())).toList();
    await prefs.setStringList('savedAddresses', addressesJson);
  }

  Future<void> _addOrUpdateAddress({Address? address}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(address: address),
      ),
    );

    if (result != null && result is Address) {
      setState(() {
        if (address == null) {
          // Add new address
          _addresses.add(result);
        } else {
          // Update existing address
          int index = _addresses.indexWhere((a) => a.id == result.id);
          if (index != -1) {
            _addresses[index] = result;
          }
        }
      });
      _saveAddresses(); // Save to SharedPreferences
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${address == null ? 'Added' : 'Updated'} address successfully!')),
      );
    }
  }

  Future<void> _deleteAddress(String id) async {
    // Show a confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: const Text('Are you sure you want to delete this address?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Dismiss dialog, return false
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Dismiss dialog, return true
              },
            ),
          ],
        );
      },
    ) ?? false; // Default to false if dialog is dismissed

    if (confirmDelete) {
      setState(() {
        _addresses.removeWhere((address) => address.id == id);
        if (_selectedAddressId == id) {
          _selectedAddressId = null; // Deselect if the deleted address was selected
          _saveSelectedLocation(null); // Clear selected location in SharedPreferences
        }
      });
      _saveAddresses(); // Save to SharedPreferences
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address deleted!')),
      );
    }
  }

  Future<void> _saveSelectedLocation(Address? address) async {
    final prefs = await SharedPreferences.getInstance();
    if (address != null) {
      final Location newLocation = Location(
        address: address.addressLine1,
        latitude: address.latitude,
        longitude: address.longitude,
      );
      await prefs.setString('userLocation', jsonEncode(newLocation.toJson()));
      setState(() {
        _selectedAddressId = address.id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delivery location set to ${address.label} - ${address.addressLine1}')),
      );
    } else {
      await prefs.remove('userLocation');
      setState(() {
        _selectedAddressId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery location cleared.')),
      );
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
        title: const Text(
          'My Address',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: _addresses.isEmpty
                ? const Center(
                    child: Text(
                      'No addresses saved yet. Add a new one!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      final isSelected = _selectedAddressId == address.id;
                      return _buildAddressCard(address, isSelected);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addOrUpdateAddress(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ADD NEW ADDRESS',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address, bool isSelected) {
    IconData labelIcon;
    Color labelColor;
    switch (address.label) {
      case 'Home':
        labelIcon = Icons.home_outlined;
        labelColor = Colors.green;
        break;
      case 'Work':
        labelIcon = Icons.work_outline;
        labelColor = Colors.blue;
        break;
      default:
        labelIcon = Icons.location_on_outlined;
        labelColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => _saveSelectedLocation(address),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.orange, width: 2) : null,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(labelIcon, color: labelColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  address.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                  onPressed: () => _addOrUpdateAddress(address: address),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteAddress(address.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address.addressLine1,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C2C3F),
              ),
            ),
            if (address.street != null && address.street!.isNotEmpty)
              Text(
                address.street!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            if (address.apartment != null && address.apartment!.isNotEmpty)
              Text(
                'Apt/Suite: ${address.apartment!}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            if (address.postCode != null && address.postCode!.isNotEmpty)
              Text(
                'Post Code: ${address.postCode!}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}