import 'package:flutter/material.dart';
import 'package:food_delivery/screens/all_food_item_screen.dart';
import 'package:food_delivery/screens/all_restaurant_screen.dart';
import 'package:food_delivery/screens/food_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_delivery/models/user_model.dart';
import 'package:food_delivery/models/location_model.dart'; // Existing Location model
import 'package:food_delivery/models/food_model.dart';
import 'package:food_delivery/models/restaurant_model.dart';

import 'package:food_delivery/models/cart_item_model.dart';
import 'package:food_delivery/screens/cart_screen.dart';
import 'dart:convert';
import 'package:food_delivery/widgets/app_drawer.dart';
import 'package:food_delivery/screens/address_screen.dart'; // Import AddressScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  Location? _currentLocation; // This will hold the selected delivery location
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  int _cartItemCount = 0;

  // Dummy Food Data (kept for context, as it's not directly modified)
  final List<Food> _allFoodItems = [
    Food(
      name: 'Classic Hot Dog',
      category: 'Hot Dog',
      imageUrl: 'https://t4.ftcdn.net/jpg/05/04/79/85/360_F_504798531_rvLu6lD1wTeeF5SVvWJhIOyyKh4ib3nd.jpg',
      price: 10000.00,
      description: 'A classic hot dog with mustard and ketchup.',
    ),
    Food(
      name: 'Spicy Hot Dog',
      category: 'Hot Dog',
      imageUrl: 'https://www.newsday.com/_next/image?url=https%3A%2F%2Fcdn.newsday.com%2Fimage-service%2Fversion%2Fc%3AZWQ1NzgyZjItNDdkZi00%3AZjItNDdkZi00ZmUyN2M4%2Ffddog210722.jpg%3Ff%3DLandscape%2B16%253A9%26w%3D770%26q%3D1&w=1920&q=80',
      price: 12000.00,
      description: 'Hot dog with jalapeños and spicy sauce.',
    ),
    Food(
      name: 'Beef Burger',
      category: 'Burger',
      imageUrl: 'https://plus.unsplash.com/premium_photo-1683619761468-b06992704398?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8YnVyZ2VyfGVufDB8fDB8fHww',
      price: 35000.00,
      description: 'Juicy beef patty with fresh vegetables.',
    ),
    Food(
      name: 'Chicken Burger',
      category: 'Burger',
      imageUrl: 'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8YnVyZ2VyfGVufDB8fDB8fHww',
      price: 30000.00,
      description: 'Grilled chicken breast burger.',
    ),
    Food(
      name: 'Pepperoni Pizza',
      category: 'Pizza',
      imageUrl: 'https://t3.ftcdn.net/jpg/03/07/65/18/360_F_307651812_yiydVwvUeeZlTCuUs4E2aqsUMUlwIo86.jpg',
      price: 45000.00,
      description: 'Classic pepperoni pizza with extra cheese.',
    ),
    Food(
      name: 'Veggie Pizza',
      category: 'Pizza',
      imageUrl: 'https://img.freepik.com/free-psd/top-view-delicious-pizza_23-2151868964.jpg?semt=ais_hybrid&w=740',
      price: 45000.00,
      description: 'Fresh vegetable pizza.',
    ),
    Food(
      name: 'Cola',
      category: 'Drinks',
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTn9Sj69fOKYUAcPyL8vG7kNdGPoJrLsCxFUA&s',
      price: 8000.00,
      description: 'Refreshing cola drink.',
    ),
    Food(
      name: 'Orange Juice',
      category: 'Drinks',
      imageUrl: 'https://www.craftginclub.co.uk/_next/image?url=https%3A%2F%2Fimages.prismic.io%2Fcgc-web%2FM2IxMTA3ZjgtZmE5Zi00ZTgxLTlhM2QtZWYwODNhMDE5ZTFm_veg-juice-cocktails.jpg%3Fauto%3Dcompress%2Cformat%26rect%3D0%2C0%2C1200%2C600%26w%3D1200%26h%3D600&w=2058&q=75',
      price: 15000.00,
      description: 'Freshly squeezed orange juice.',
    ),
  ];

  // Dummy Restaurant Data (kept for context, as it's not directly modified)
  final List<Restaurant> _allRestaurants = [
    Restaurant(
      name: 'Rose Garden Restaurant',
      categories: 'Burger - Chicken - Riche - Wings',
      imageUrl: 'https://images.unsplash.com/photo-1613946069412-38f7f1ff0b65?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Njh8fHJlc3RhdXJhbnR8ZW58MHx8MHx8fDA%3D',
      rating: 4.7,
      deliveryFee: 'Free',
      deliveryTime: '20 min',
    ),
    Restaurant(
      name: 'The Green Bowl',
      categories: 'Healthy - Salads - Vegan',
      imageUrl: 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDl8fHJlc3RhdXJhbnR8ZW58MHx8MHx8fDA%3D',
      rating: 4.5,
      deliveryFee: 'LAK 10,000',
      deliveryTime: '30 min',
    ),
    Restaurant(
      name: 'Burger Bistro',
      categories: 'Burgers',
      imageUrl: 'https://images.unsplash.com/photo-1579027989536-b7b1f875659b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzV8fHJlc3RhdXJhbnR8ZW58MHx8MHx8fDA%3D',
      rating: 4.2,
      deliveryFee: 'LAK 5,000',
      deliveryTime: '25 min',
    ),
    Restaurant(
      name: 'Smokin\' Burger',
      categories: 'Burgers - BBQ',
      imageUrl: 'https://images.unsplash.com/photo-1502998070258-dc1338445ac2?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mjd8fHJlc3RhdXJhbnR8ZW58MHx8MHx8fDA%3D',
      rating: 4.8,
      deliveryFee: 'Free',
      deliveryTime: '15 min',
    ),
    Restaurant(
      name: 'Kabab Restaurant',
      categories: 'Kabab - Middle Eastern',
      imageUrl: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?q=80&w=1074&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      rating: 4.0,
      deliveryFee: 'LAK 8,000',
      deliveryTime: '35 min',
    ),
  ];

  List<Food> get _filteredFoodItems {
    List<Food> itemsToFilter = _allFoodItems;

    if (_searchController.text.isEmpty && _selectedCategory != 'All') {
      itemsToFilter =
          itemsToFilter.where((food) => food.category == _selectedCategory).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      itemsToFilter = itemsToFilter
          .where((food) =>
              food.name.toLowerCase().contains(query) ||
              food.description.toLowerCase().contains(query) ||
              food.category.toLowerCase().contains(query))
          .toList();
    }
    return itemsToFilter;
  }

  List<Restaurant> get _filteredRestaurantItems {
    List<Restaurant> itemsToFilter = _allRestaurants;

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      itemsToFilter = itemsToFilter
          .where((restaurant) =>
              restaurant.name.toLowerCase().contains(query) ||
              restaurant.categories.toLowerCase().contains(query))
          .toList();
    }
    return itemsToFilter;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCartItemCount();
    _loadCurrentLocation(); // Load the selected location
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
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

  Future<void> _loadCurrentLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationJson = prefs.getString('userLocation');
    setState(() {
      if (locationJson != null) {
        _currentLocation = Location.fromJson(jsonDecode(locationJson));
      } else {
        _currentLocation = null; // No location selected
      }
    });
  }

  Future<void> _loadCartItemCount() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartJsonList = prefs.getStringList('cartItems') ?? [];
    int count = 0;
    for (var jsonString in cartJsonList) {
      try {
        CartItem item = CartItem.fromJson(jsonDecode(jsonString));
        count += item.quantity;
      } catch (e) {
        print('Error decoding cart item: $e');
      }
    }
    setState(() {
      _cartItemCount = count;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
    });
  }

  void _onSearchChanged() {
    setState(() {
      // Rebuilds the widget
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchController.text.isNotEmpty;
    List<Food> currentFoodItems = _filteredFoodItems;
    List<Restaurant> currentRestaurantItems = _filteredRestaurantItems;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: GestureDetector(
          onTap: () async {
            // Navigate to AddressScreen and await result (if any selection is made)
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddressScreen()),
            );
            _loadCurrentLocation(); // Reload the selected location after returning
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DELIVER TO',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Row(
                children: [
                  Text(
                    _currentLocation?.address ?? 'Select Location',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  ).then((_) => _loadCartItemCount());
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hey ${_currentUser?.name ?? 'User'}, Good Afternoon!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C3F),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search dishes, restaurants',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) => _onSearchChanged(),
              ),
            ),
            const SizedBox(height: 24),
            if (!isSearching) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C3F),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllFoodItemsScreen(allFoodItems: _allFoodItems),
                        ),
                      ).then((_) => _loadCartItemCount());
                    },
                    child: Row(
                      children: const [
                        Text(
                          'See All',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('All', Icons.local_fire_department,
                        isSelected: _selectedCategory == 'All'),
                    _buildCategoryChip('Hot Dog', Icons.fastfood,
                        isSelected: _selectedCategory == 'Hot Dog'),
                    _buildCategoryChip('Burger', Icons.lunch_dining,
                        isSelected: _selectedCategory == 'Burger'),
                    _buildCategoryChip('Pizza', Icons.local_pizza,
                        isSelected: _selectedCategory == 'Pizza'),
                    _buildCategoryChip('Drinks', Icons.local_drink,
                        isSelected: _selectedCategory == 'Drinks'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (currentFoodItems.isNotEmpty) ...[
              Text(
                isSearching ? 'Dishes Matching "${_searchController.text}"' : 'Dishes',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C3F),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: currentFoodItems.map((food) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailScreen(food: food),
                        ),
                      ).then((_) => _loadCartItemCount());
                    },
                    child: _buildFoodItemCard(food),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            if (currentRestaurantItems.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSearching ? 'Restaurants Matching "${_searchController.text}"' : 'Open Restaurants',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C3F),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllRestaurantsScreen(allRestaurants: _allRestaurants),
                        ),
                      );
                    },
                    child: Row(
                      children: const [
                        Text(
                          'See All',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: currentRestaurantItems.map((restaurant) {
                  return _buildRestaurantCard(
                    restaurant.name,
                    restaurant.categories,
                    restaurant.imageUrl,
                    restaurant.rating.toString(),
                    restaurant.deliveryFee,
                    restaurant.deliveryTime,
                  );
                }).toList(),
              ),
            ],
            if (isSearching && currentFoodItems.isEmpty && currentRestaurantItems.isEmpty)
              const Center(child: Text('No results found for your search query.')),
            if (!isSearching && currentFoodItems.isEmpty && currentRestaurantItems.isEmpty)
              const Center(child: Text('No food items or restaurants available.')),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String text, IconData icon, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _onCategorySelected(text),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey[700], size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
      String name, String categories, String imageUrl, String rating, String deliveryFee, String deliveryTime) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C3F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  categories,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(rating, style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(width: 16),
                    Icon(Icons.delivery_dining, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(deliveryFee, style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(width: 16),
                    Icon(Icons.timer, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(deliveryTime, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItemCard(Food food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Hero(
              tag: 'foodImage-${food.name}',
              child: Image.network(
                food.imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C3F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LAK ${food.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}