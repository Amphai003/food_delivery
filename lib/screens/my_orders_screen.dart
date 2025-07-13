import 'package:flutter/material.dart';
import 'package:food_delivery/screens/home_screen.dart';
import 'package:food_delivery/screens/track_order_screen.dart'; // Import TrackOrderScreen
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:food_delivery/models/cart_item_model.dart'; // Ensure this is the updated CartItem model

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CartItem> _ongoingOrders = []; // For items in ongoing orders
  List<CartItem> _historyOrders =
      []; // For items in history orders (completed/cancelled)

  @override
  void initState() {
    super.initState();
    debugPrint('MyOrdersScreen: initState called'); // Debugging print
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
    // Listen for tab changes if you need to refresh data when tabs are switched
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    debugPrint('MyOrdersScreen: dispose called'); // Debugging print
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      debugPrint(
        'MyOrdersScreen: Tab selection changing, reloading orders.',
      ); // Debugging print
      // Reload orders when switching tabs to ensure the latest state is shown
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    debugPrint('MyOrdersScreen: _loadOrders called'); // Debugging print
    final prefs = await SharedPreferences.getInstance();

    // Load ongoing orders
    List<String> lastOrderJsonList =
        prefs.getStringList('lastOrderItems') ?? [];
    List<CartItem> loadedOngoingOrders = [];
    for (var jsonString in lastOrderJsonList) {
      try {
        loadedOngoingOrders.add(CartItem.fromJson(jsonDecode(jsonString)));
      } catch (e) {
        debugPrint(
          'MyOrdersScreen: Error decoding ongoing order item: $e',
        ); // Use debugPrint
      }
    }

    // Load history orders
    List<String> historyJsonList = prefs.getStringList('orderHistory') ?? [];
    List<CartItem> loadedHistoryOrders = [];
    for (var jsonString in historyJsonList) {
      try {
        loadedHistoryOrders.add(CartItem.fromJson(jsonDecode(jsonString)));
      } catch (e) {
        debugPrint(
          'MyOrdersScreen: Error decoding history order item: $e',
        ); // Use debugPrint
      }
    }

    if (mounted) {
      // Ensure widget is still in the tree before calling setState
      setState(() {
        _ongoingOrders = loadedOngoingOrders;
        _historyOrders = loadedHistoryOrders;
      });
      debugPrint(
        'MyOrdersScreen: Orders loaded and setState called. Ongoing: ${_ongoingOrders.length}, History: ${_historyOrders.length}',
      ); // Debugging print
    } else {
      debugPrint(
        'MyOrdersScreen: _loadOrders finished, but widget is not mounted.',
      ); // Debugging print
    }
  }

  Future<void> _saveOrders() async {
    debugPrint('MyOrdersScreen: _saveOrders called'); // Debugging print
    final prefs = await SharedPreferences.getInstance();
    List<String> ongoingJsonList = _ongoingOrders
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    List<String> historyJsonList = _historyOrders
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList(
      'lastOrderItems',
      ongoingJsonList,
    ); // Save ongoing orders
    await prefs.setStringList(
      'orderHistory',
      historyJsonList,
    ); // Save history orders
    debugPrint('MyOrdersScreen: Orders saved.'); // Debugging print
  }

  Future<void> _cancelOrder(int index) async {
    debugPrint(
      'MyOrdersScreen: _cancelOrder called for index $index',
    ); // Debugging print
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
              onPressed: () => Navigator.of(
                context,
              ).pop(true), // User confirmed cancellation
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      // Check mounted after async operation
      setState(() {
        CartItem cancelledItem = _ongoingOrders.removeAt(index);
        // Add the cancelled item to history with a 'Cancelled' status
        _historyOrders.add(cancelledItem.copyWith(status: 'Cancelled'));
        debugPrint(
          'MyOrdersScreen: Order at index $index cancelled and moved to history.',
        ); // Debugging print
      });
      await _saveOrders(); // Persist changes
      if (mounted) {
        // Check mounted again before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully.')),
        );
      }
    }
  }

  Future<void> _deleteAllHistory() async {
    debugPrint('MyOrdersScreen: _deleteAllHistory called'); // Debugging print
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
      await prefs.setStringList(
        'orderHistory',
        [],
      ); // Clear history in SharedPreferences
      setState(() {
        _historyOrders.clear(); // Clear local list
      });
      debugPrint('MyOrdersScreen: All history items deleted.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order history cleared successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('MyOrdersScreen: build called'); // Debugging print
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            // Navigate to AddCardScreen
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
          // Add a "Delete All History" button here if the History tab is active
          // For simplicity, I'll place it in the TabBarView for the History tab
          // You could also use a Listener on _tabController and show/hide it in AppBar actions
          if (_tabController.index == 1) // Only show if History tab is selected
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              tooltip: 'Clear All History',
              onPressed: _deleteAllHistory,
            ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {
              debugPrint('MyOrdersScreen: More options button pressed.');
              // TODO: Implement more options for orders if needed
            },
          ),
          const SizedBox(width: 8),
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
      debugPrint(
        'MyOrdersScreen: Building Ongoing tab - No ongoing orders.',
      ); // Debugging print
      return const Center(child: Text('You have no ongoing orders.'));
    }
    debugPrint(
      'MyOrdersScreen: Building Ongoing tab - Showing ${_ongoingOrders.length} orders.',
    ); // Debugging print
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _ongoingOrders.length,
      itemBuilder: (context, index) {
        final item = _ongoingOrders[index];
        // For ongoing orders, provide track and cancel options
        return _buildOrderItemCard(
          item,
          item.status ??
              'Ongoing', // Use item.status if available, default to 'Ongoing'
          trackOrder: true,
          cancelOrder: true,
          onCancel: () => _cancelOrder(index), // Pass the cancel function
        );
      },
    );
  }

  Widget _buildHistoryOrdersTab() {
    if (_historyOrders.isEmpty) {
      debugPrint(
        'MyOrdersScreen: Building History tab - No order history.',
      ); // Debugging print
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You have no order history.'),
              // You can optionally add a "clear" button here as well, but it's now in the AppBar
            ],
          ),
        ),
      );
    }
    debugPrint(
      'MyOrdersScreen: Building History tab - Showing ${_historyOrders.length} orders.',
    ); // Debugging print
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _historyOrders.length,
      itemBuilder: (context, index) {
        final item = _historyOrders[index];
        // For history, status can be "Completed" or "Cancelled"
        return _buildOrderItemCard(
          item,
          item.status ?? 'Completed', // Use item.status, default to 'Completed'
          rateOrder: true,
          reOrder: true,
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
    VoidCallback? onCancel, // New callback for cancel button
  }) {
    // Adding more robust null checks/defaults for display
    final String itemName = item.name ?? 'Unknown Item';
    final double itemTotalPrice = (item.price ?? 0.0) * (item.quantity ?? 0);
    final int itemQuantity = item.quantity ?? 0;
    final String imageUrl =
        item.imageUrl ?? ''; // Provide a default empty string for image URL

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
                  imageUrl, // Use the null-checked imageUrl
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint(
                      'MyOrdersScreen: Image loading error for $itemName: $error',
                    ); // Debugging print
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
                      itemName, // Use null-checked itemName
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C3F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LAK ${itemTotalPrice.toStringAsFixed(2)}', // Use calculated total price
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      '$itemQuantity Items', // Use null-checked quantity
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '#${(100000 + (item.hashCode % 900000)).toString()}', // Simple pseudo-order ID
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
                    onPressed: () {
                      debugPrint(
                        'MyOrdersScreen: Rate button tapped for $itemName',
                      ); // Debugging print
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Rate "$itemName" tapped!')),
                      );
                      // TODO: Implement rate order functionality
                    },
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
                    onPressed: () {
                      debugPrint(
                        'MyOrdersScreen: Re-Order button tapped for $itemName',
                      ); // Debugging print
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Re-Order "$itemName" tapped!')),
                      );
                      // TODO: Implement re-order functionality (e.g., add to cart)
                    },
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
                      debugPrint(
                        'MyOrdersScreen: Track Order button tapped for $itemName. Navigating to TrackOrderScreen.',
                      ); // Debugging print
                      // IMPORTANT: Use Navigator.push here to keep MyOrdersScreen on stack
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrackOrderScreen(),
                        ),
                      ).then((_) {
                        debugPrint(
                          'MyOrdersScreen: Returned from TrackOrderScreen. Reloading orders.',
                        ); // Debugging print
                        // This callback runs when TrackOrderScreen is popped
                        _loadOrders(); // Reload orders to reflect potential completion/cancellation
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
                    onPressed: onCancel, // Use the provided callback for cancel
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
