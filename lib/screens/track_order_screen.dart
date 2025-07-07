import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Import flutter_map
import 'package:food_delivery/screens/home_screen.dart';
import 'package:latlong2/latlong.dart'; // Import latlong2 for LatLng
import 'package:food_delivery/models/cart_item_model.dart';
import 'package:food_delivery/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async'; // For Completer

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({Key? key}) : super(key: key);

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final MapController _mapController =
      MapController(); // Use MapController for flutter_map
  List<CartItem> _orderedItems = [];
  Location? _deliveryLocation;
  String _estimatedArrivalTime = 'Calculating...'; // e.g., "25-30 min"
  String _orderTime = ''; // e.g., "Ordered At 06 Sept, 10:00pm"

  // Dummy coordinates for demonstration
  static const LatLng _restaurantLocation = LatLng(
    17.958141,
    102.630598,
  ); // Example: Vientiane center
  static LatLng _userDeliveryLocation = LatLng(
    17.939434,
    102.626607,
  ); // Example: slightly east of center

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    final prefs = await SharedPreferences.getInstance();

    // Load ordered items (assuming they were saved temporarily after payment)
    List<String> orderedItemsJsonList =
        prefs.getStringList('lastOrderItems') ?? [];
    print('TrackOrderScreen: Loaded lastOrderItems raw: $orderedItemsJsonList');

    List<CartItem> loadedItems = [];
    for (var jsonString in orderedItemsJsonList) {
      try {
        loadedItems.add(CartItem.fromJson(jsonDecode(jsonString)));
      } catch (e) {
        print('TrackOrderScreen: Error decoding ordered item: $e');
      }
    }
    print(
      'TrackOrderScreen: Parsed loadedItems: ${loadedItems.map((e) => e.name).toList()}',
    );

    // Load user delivery location
    final locationJson = prefs.getString('userLocation');
    Location? loadedLocation;
    if (locationJson != null) {
      try {
        loadedLocation = Location.fromJson(jsonDecode(locationJson));
        if (loadedLocation.latitude != null &&
            loadedLocation.longitude != null) {
          _userDeliveryLocation = LatLng(
            loadedLocation.latitude!,
            loadedLocation.longitude!,
          );
        }
      } catch (e) {
        print('TrackOrderScreen: Error decoding location: $e');
      }
    }

    // Simulate estimated arrival time and order time
    setState(() {
      _orderedItems = loadedItems;
      _deliveryLocation = loadedLocation;
      _estimatedArrivalTime = '25-30 min'; // Dummy value
      _orderTime =
          'Ordered At ${DateTime.now().day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'][DateTime.now().month - 1]}, ${TimeOfDay.now().hourOfPeriod}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}${TimeOfDay.now().period.name}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: const Text(
          'Track Order',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController, // Assign map controller
                  options: MapOptions(
                    initialCenter: LatLng(
                      (_restaurantLocation.latitude +
                              _userDeliveryLocation.latitude) /
                          2,
                      (_restaurantLocation.longitude +
                              _userDeliveryLocation.longitude) /
                          2,
                    ),
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _restaurantLocation,
                          child: const Icon(
                            Icons.restaurant, // Or a custom image asset
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                        Marker(
                          point: _userDeliveryLocation,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40.0,
                          ),
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [_restaurantLocation, _userDeliveryLocation],
                          color: Colors.orange,
                          strokeWidth: 5.0,
                        ),
                      ],
                    ),
                  ],
                ),
                // Estimated arrival time overlay
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Arrival:',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          _estimatedArrivalTime,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C3F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Order Details Card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C3F),
                      ),
                    ),
                    Text(
                      _orderTime,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Ordered Items List
                _orderedItems.isEmpty
                    ? const Center(child: Text('No order details found.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _orderedItems.length,
                        itemBuilder: (context, index) {
                          final item = _orderedItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.imageUrl,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 50,
                                        width: 50,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2C2C3F),
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}x',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'LAK ${(item.price * item.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
