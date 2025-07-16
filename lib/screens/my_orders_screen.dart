import 'package:flutter/material.dart';
import 'package:food_delivery/screens/home_screen.dart';
import 'package:food_delivery/screens/track_order_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:food_delivery/models/cart_item_model.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CartItem> _ongoingOrders = [];
  List<CartItem> _historyOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> lastOrderJsonList =
        prefs.getStringList('lastOrderItems') ?? [];
    List<CartItem> loadedOngoingOrders = [];
    for (var jsonString in lastOrderJsonList) {
      try {
        loadedOngoingOrders.add(CartItem.fromJson(jsonDecode(jsonString)));
      } catch (e) {
        // Handle decoding errors gracefully
      }
    }

    List<String> historyJsonList = prefs.getStringList('orderHistory') ?? [];
    List<CartItem> loadedHistoryOrders = [];
    for (var jsonString in historyJsonList) {
      try {
        loadedHistoryOrders.add(CartItem.fromJson(jsonDecode(jsonString)));
      } catch (e) {
        // Handle decoding errors gracefully
      }
    }

    if (mounted) {
      setState(() {
        _ongoingOrders = loadedOngoingOrders;
        _historyOrders = loadedHistoryOrders;
      });
    }
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ongoingJsonList =
        _ongoingOrders.map((item) => jsonEncode(item.toJson())).toList();
    List<String> historyJsonList =
        _historyOrders.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('lastOrderItems', ongoingJsonList);
    await prefs.setStringList('orderHistory', historyJsonList);
  }

  Future<void> _cancelOrder(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Order?'),
          content: const Text(
            'Are you sure you want to cancel this order? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // User chose not to cancel
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        CartItem cancelledItem = _ongoingOrders.removeAt(index);
        _historyOrders.add(cancelledItem.copyWith(status: 'Cancelled'));
      });
      await _saveOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully.')),
        );
      }
    }
  }

  Future<void> _deleteAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear History?'),
          content: const Text(
            'Are you sure you want to delete all order history? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('orderHistory', []);
      setState(() {
        _historyOrders.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order history cleared successfully.')),
        );
      }
    }
  }

  // New: Function to handle rating an order
  Future<void> _rateOrder(CartItem item) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rate "${item.name ?? 'Item'}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How would you rate this order?'),
              const SizedBox(height: 10),
              // You can add a more sophisticated rating widget here (e.g., star rating)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return const Icon(Icons.star_border, color: Colors.amber);
                }),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thank you for rating "${item.name ?? 'Item'}"!')),
                );
                // In a real app, send rating to backend
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // New: Function to handle re-ordering an item
  Future<void> _reOrder(CartItem item) async {
    // For demonstration, we'll add it back to ongoing orders.
    // In a real app, you might add it to the cart and then navigate to the cart/checkout.
    if (mounted) {
      setState(() {
        // Create a new CartItem instance with a fresh status for re-order
        _ongoingOrders.add(item.copyWith(status: 'Re-ordered', quantity: item.quantity ?? 1));
      });
      await _saveOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${item.name ?? 'Item'}" re-ordered!')),
        );
        // Optionally navigate to HomeScreen or CartScreen after re-ordering
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false, // Clears the stack and goes to HomeScreen
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_tabController.index == 1 && _historyOrders.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              tooltip: 'Clear All History',
              onPressed: _deleteAllHistory,
            ),
          // Removed the Icons.more_horiz button
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Ongoing'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOngoingOrdersTab(), _buildHistoryOrdersTab()],
      ),
    );
  }

  Widget _buildOngoingOrdersTab() {
    if (_ongoingOrders.isEmpty) {
      return const Center(child: Text('You have no ongoing orders.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _ongoingOrders.length,
      itemBuilder: (context, index) {
        final item = _ongoingOrders[index];
        return _buildOrderItemCard(
          item,
          item.status ?? 'Ongoing',
          trackOrder: true,
          cancelOrder: true,
          onCancel: () => _cancelOrder(index),
        );
      },
    );
  }

  Widget _buildHistoryOrdersTab() {
    if (_historyOrders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You have no order history.'),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _historyOrders.length,
      itemBuilder: (context, index) {
        final item = _historyOrders[index];
        return _buildOrderItemCard(
          item,
          item.status ?? 'Completed',
          rateOrder: true,
          reOrder: true,
          onRate: () => _rateOrder(item), // Pass the rate function
          onReOrder: () => _reOrder(item), // Pass the re-order function
        );
      },
    );
  }

  Widget _buildOrderItemCard(
    CartItem item,
    String status, {
    bool trackOrder = false,
    bool cancelOrder = false,
    bool rateOrder = false,
    bool reOrder = false,
    VoidCallback? onCancel,
    VoidCallback? onRate, // New callback for rate button
    VoidCallback? onReOrder, // New callback for re-order button
  }) {
    final String itemName = item.name ?? 'Unknown Item';
    final double itemTotalPrice = (item.price ?? 0.0) * (item.quantity ?? 0);
    final int itemQuantity = item.quantity ?? 0;
    final String imageUrl = item.imageUrl ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 60,
                      width: 60,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C3F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LAK ${itemTotalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      '$itemQuantity Items',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '#${(100000 + (item.hashCode % 900000)).toString()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: status == 'Completed'
                          ? Colors.green
                          : (status == 'Cancelled'
                              ? Colors.red
                              : Colors.orange),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (rateOrder)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRate, // Use the new onRate callback
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Rate'),
                  ),
                ),
              if (rateOrder && reOrder) const SizedBox(width: 10),
              if (reOrder)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReOrder, // Use the new onReOrder callback
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Re-Order',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              if (trackOrder)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrackOrderScreen(),
                        ),
                      ).then((_) {
                        _loadOrders();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Track Order',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              if (trackOrder && cancelOrder) const SizedBox(width: 10),
              if (cancelOrder)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}