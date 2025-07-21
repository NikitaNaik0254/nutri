import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/food_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _cartItemsFuture;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() {
    _cartItemsFuture = _fetchCartItems();
  }

  Future<List<Map<String, dynamic>>> _fetchCartItems() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('cart')
          .select('''
            id,
            quantity,
            recipes:recipe_id (
              id, name, image_url, time_to_make,
              calories, protein, carbs, fat,
              price
            )
          ''')
          .eq('user_id', userId)
          .order('added_at', ascending: false);

      final items = List<Map<String, dynamic>>.from(response);
      _calculateTotal(items);
      return items;
    } catch (e) {
      debugPrint('Error fetching cart items: $e');
      return [];
    }
  }

  void _calculateTotal(List<Map<String, dynamic>> items) {
    _totalPrice = items.fold(0.0, (sum, item) {
      final recipe = item['recipes'] as Map<String, dynamic>;
      final price = (recipe['price'] ?? 0.0) as double;
      final quantity = (item['quantity'] ?? 1) as int;
      return sum + (price * quantity);
    });
  }

  Future<void> _updateQuantity(int cartItemId, int newQuantity) async {
    try {
      if (newQuantity < 1) {
        await _removeFromCart(cartItemId);
        return;
      }

      await _supabase
          .from('cart')
          .update({'quantity': newQuantity})
          .eq('id', cartItemId);

      setState(() {
        _loadCartItems();
      });
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> _removeFromCart(int cartItemId) async {
    try {
      await _supabase.from('cart').delete().eq('id', cartItemId);
      setState(() {
        _loadCartItems();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed from cart')),
      );
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

  Future<void> _checkout() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // Create order
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'user_id': userId,
            'total_amount': _totalPrice,
            'status': 'pending',
          })
          .select()
          .single();

      // Move cart items to order items
      final cartItems = await _fetchCartItems();
      for (final item in cartItems) {
        await _supabase.from('order_items').insert({
          'order_id': orderResponse['id'],
          'recipe_id': item['recipes']['id'],
          'quantity': item['quantity'],
          'price': item['recipes']['price'],
        });
      }

      // Clear cart
      await _supabase.from('cart').delete().eq('user_id', userId);

      setState(() {
        _loadCartItems();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (e) {
      debugPrint('Error during checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Cart',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cartItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cartItems = snapshot.data ?? [];

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add some delicious items to get started!',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final recipe = item['recipes'] as Map<String, dynamic>;
                    final quantity = item['quantity'] as int;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: recipe['image_url'] != null
                                ? CachedNetworkImage(
                                    imageUrl: recipe['image_url'],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(color: Colors.grey[200]),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.fastfood),
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.fastfood),
                                  ),
                          ),
                        ),
                        title: Text(
                          recipe['name'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${(recipe['price'] ?? 0.0).toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () =>
                                      _updateQuantity(item['id'], quantity - 1),
                                ),
                                Text(
                                  quantity.toString(),
                                  style: GoogleFonts.poppins(),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () =>
                                      _updateQuantity(item['id'], quantity + 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFromCart(item['id']),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FoodDetailScreen(foodItem: recipe),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${_totalPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _checkout,
                        child: Text(
                          'Checkout',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}