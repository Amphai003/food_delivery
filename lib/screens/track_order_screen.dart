import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Import flutter_map
import 'package:food_delivery/screens/my_orders_screen.dart';
import 'package:latlong2/latlong.dart'; // Import latlong2 for LatLng
import 'package:food_delivery/models/cart_item_model.dart'; // Ensure this is the updated model with 'status'
import 'package:food_delivery/models/location_model.dart'; // Your provided Location model
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async'; // For Timer
import 'package:flutter/foundation.dart' as foundation; // For debugPrint

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({Key? key}) : super(key: key);

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final MapController _mapController = MapController();
  List<CartItem> _orderedItems = [];
  Location? _deliveryLocation; // This would typically be the user's saved delivery address
  String _estimatedArrivalTime = 'Calculating...'; // e.g., "25-30 min"
  String _orderTime = ''; // e.g., "Ordered At 06 Sept, 10:00pm"
  Timer? _orderCompletionTimer; // Timer for simulating order completion

  // Dummy coordinates for demonstration (Vientiane, Laos)
  // You might want to get restaurant location from a food item or configuration
  static const LatLng _restaurantLocation = LatLng(
    17.9691,
    102.6105,
  ); // Example: Near Patuxay
  LatLng _userDeliveryLocation = LatLng(
    // Marked as const, but it's reassigned, so removed const
    17.9818,
    102.6328,
  ); // Example: Near That Luang (will be updated from SharedPreferences)

  @override
  void initState() {
    super.initState();
    foundation.debugPrint(
        'TrackOrderScreen: initState called'); // Debugging print
    _loadOrderDetails();
  }

  @override
  void dispose() {
    foundation.debugPrint(
        'TrackOrderScreen: dispose called'); // Debugging print
    _orderCompletionTimer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  Future<void> _loadOrderDetails() async {
    foundation.debugPrint(
        'TrackOrderScreen: _loadOrderDetails called'); // Debugging print
    final prefs = await SharedPreferences.getInstance();

    List<String> orderedItemsJsonList =
        prefs.getStringList('lastOrderItems') ?? [];
    List<CartItem> loadedItems = [];
    for (var jsonString in orderedItemsJsonList) {
      try {
        loadedItems.add(CartItem.fromJson(jsonDecode(jsonString)));
      } catch (e) {
        foundation.debugPrint(
            'TrackOrderScreen: Error decoding ordered item: $e'); // Use debugPrint
      }
    }

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
          foundation.debugPrint(
              'TrackOrderScreen: User delivery location loaded: ${_userDeliveryLocation.latitude}, ${_userDeliveryLocation.longitude}'); // Debugging print
        }
      } catch (e) {
        foundation.debugPrint(
            'TrackOrderScreen: Error decoding user location: $e'); // Use debugPrint
      }
    }

    if (mounted) {
      // Ensure widget is still in the tree before calling setState
      setState(() {
        _orderedItems = loadedItems;
        _deliveryLocation = loadedLocation;
        _estimatedArrivalTime = '20-25 min'; // Dummy value
        _orderTime =
            'Ordered At ${DateTime.now().day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][DateTime.now().month - 1]}, ${TimeOfDay.now().hourOfPeriod}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}${TimeOfDay.now().period.name}';
      });
      foundation.debugPrint(
          'TrackOrderScreen: Order details loaded and setState called. Items: ${_orderedItems.length}'); // Debugging print
      // Start a timer to simulate order completion
      _startOrderCompletionTimer();
    } else {
      foundation.debugPrint(
          'TrackOrderScreen: _loadOrderDetails finished, but widget is not mounted.'); // Debugging print
    }
  }

  void _startOrderCompletionTimer() {
    // Only start if there are ongoing orders and they haven't been "completed" or "cancelled" yet
    if (_orderedItems.isNotEmpty &&
        _orderedItems.any(
            (item) => item.status == null || item.status == 'Ongoing')) {
      _orderCompletionTimer = Timer(const Duration(seconds: 15), () async {
        if (mounted) {
          foundation.debugPrint(
              'TrackOrderScreen: Order completion timer fired.'); // Debugging print
          // Check if the widget is still in the tree
          await _markOrderAsCompleted();
          if (mounted) {
            // Check mounted again before showing SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Your order has been delivered!')),
            );
          }
          // Optional: You could pop the screen automatically here,
          // but letting the user see "Delivered!" for a moment might be better.
          // Navigator.of(context).pop();
        } else {
          foundation.debugPrint(
              'TrackOrderScreen: Order completion timer fired, but widget is not mounted.'); // Debugging print
        }
      });
      foundation.debugPrint(
          'TrackOrderScreen: Order completion timer started.'); // Debugging print
    } else {
      foundation.debugPrint(
          'TrackOrderScreen: No ongoing orders or already completed/cancelled, timer not started.'); // Debugging print
    }
  }

  Future<void> _markOrderAsCompleted() async {
    foundation.debugPrint(
        'TrackOrderScreen: _markOrderAsCompleted called.'); // Debugging print
    final prefs = await SharedPreferences.getInstance();
    List<String> historyJsonList = prefs.getStringList('orderHistory') ?? [];
    List<CartItem> currentHistory = [];
    for (var jsonString in historyJsonList) {
      try {
        currentHistory.add(CartItem.fromJson(jsonDecode(jsonString)));
      } catch (e) {
        foundation.debugPrint(
            'TrackOrderScreen: Error decoding history item during completion: $e'); // Use debugPrint
      }
    }

    // Add ongoing items to history with 'Completed' status
    for (var item in _orderedItems) {
      // Ensure the item exists and hasn't been cancelled by MyOrdersScreen in the meantime
      if (item.status != 'Cancelled') {
        // Only mark as completed if not already cancelled
        currentHistory.add(item.copyWith(status: 'Completed'));
        foundation.debugPrint(
            'TrackOrderScreen: Item "${item.name}" marked as Completed.'); // Debugging print
      } else {
        // If it was cancelled, just add it as is (with 'Cancelled' status already)
        currentHistory.add(item);
        foundation.debugPrint(
            'TrackOrderScreen: Item "${item.name}" was already Cancelled, adding to history.'); // Debugging print
      }
    }

    // Clear 'lastOrderItems'
    await prefs.setStringList('lastOrderItems', []);
    // Save updated history
    await prefs.setStringList(
      'orderHistory',
      currentHistory.map((item) => jsonEncode(item.toJson())).toList(),
    );
    foundation.debugPrint(
        'TrackOrderScreen: Orders moved to history and lastOrderItems cleared.'); // Debugging print

    if (mounted) {
      // Ensure widget is still in the tree before calling setState
      setState(() {
        _orderedItems.clear(); // Clear local ongoing orders
        _estimatedArrivalTime = 'Delivered!';
      });
      foundation.debugPrint(
          'TrackOrderScreen: setState after completion.'); // Debugging print
    } else {
      foundation.debugPrint(
          'TrackOrderScreen: _markOrderAsCompleted finished, but widget is not mounted.'); // Debugging print
    }
  }

  @override
  Widget build(BuildContext context) {
    foundation.debugPrint('TrackOrderScreen: build called'); // Debugging print
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            // FIX: Always navigate to MyOrdersScreen when the back button is pressed.
            // This handles cases where TrackOrderScreen was pushed using pushReplacement
            // (e.g., from CongratulationsScreen), ensuring the user always lands on MyOrdersScreen.
            Navigator.pushAndRemoveUntil( // Use pushAndRemoveUntil
              context,
              MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
              (Route<dynamic> route) => false, // Remove all previous routes until MyOrdersScreen is the only one.
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
                  mapController: _mapController,
                  options: MapOptions(
                    // Center the map between restaurant and delivery location
                    initialCenter: LatLng(
                      (_restaurantLocation.latitude +
                              _userDeliveryLocation.latitude) /
                          2,
                      (_restaurantLocation.longitude +
                              _userDeliveryLocation.longitude) /
                          2,
                    ),
                    initialZoom: 13.0, // Adjusted zoom for better view
                    // Optionally set bounds to ensure both markers are visible:
                    // bounds: LatLngBounds(_restaurantLocation, _userDeliveryLocation),
                    // boundsOptions: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
                    // interactivity: InteractiveFlag.none, // Uncomment to disable map interaction
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                      // It's good practice to provide a user agent
                      userAgentPackageName: 'com.example.food_delivery_app',
                    ),
                    MarkerLayer(
                      markers: [
                        // Restaurant Marker
                        Marker(
                          point: _restaurantLocation,
                          width: 80.0,
                          height: 80.0,
                          child: Column(
                            children: [
                              Icon(
                                Icons
                                    .restaurant, // You can use a custom asset here
                                color: Colors.red,
                                size: 30.0,
                              ),
                              Text(
                                'Restaurant',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        // User Delivery Location Marker
                        Marker(
                          point: _userDeliveryLocation,
                          width: 80.0,
                          height: 80.0,
                          child: Column(
                            children: [
                              Icon(
                                Icons
                                    .location_on, // You can use a custom asset here
                                color: Colors.blue,
                                size: 30.0,
                              ),
                              // Use the 'address' field from your Location model
                              Text(
                                _deliveryLocation?.address ?? 'Your Location',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          ),
                      ],
                    ),
                    // Polyline showing path
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
                    ? const Center(
                        child: Text('No ongoing order details found.'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _orderedItems.length,
                        itemBuilder: (context, index) {
                          final item = _orderedItems[index];
                          // Adding more robust null checks/defaults for display
                          final String itemName = item.name ?? 'Unknown Item';
                          final double itemPrice = item.price ?? 0.0;
                          final int itemQuantity = item.quantity ?? 0;
                          final String imageUrl = item.imageUrl ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      foundation.debugPrint(
                                          'TrackOrderScreen: Image loading error for $itemName: $error');
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
                                        itemName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2C2C3F),
                                        ),
                                      ),
                                      Text(
                                        '${itemQuantity}x',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'LAK ${(itemPrice * itemQuantity).toStringAsFixed(2)}',
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