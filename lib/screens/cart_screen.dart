import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/checkout_screen.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _cartItemsFuture;
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _cartItemsFuture = _fetchCartItems();
    });
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
            recipes:recipes (
              id, 
              name, 
              description, 
              image_url, 
              category, 
              time_to_make,
              calories,
              protein,
              carbs,
              fat
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _cartItems = List<Map<String, dynamic>>.from(response);
      return _cartItems;
    } catch (e) {
      debugPrint('Error fetching cart items: $e');
      return [];
    }
  }

  Future<void> _updateQuantity(String cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await _supabase.from('cart').delete().eq('id', cartItemId);
      } else {
        await _supabase
            .from('cart')
            .update({'quantity': newQuantity})
            .eq('id', cartItemId);
      }
      await _loadCartItems();
    } catch (e) {
      debugPrint('Error updating quantity: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeItem(String cartItemId) async {
    try {
      await _supabase.from('cart').delete().eq('id', cartItemId);
      await _loadCartItems();
    } catch (e) {
      debugPrint('Error removing item: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCartItems,
          ),
        ],
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

          _cartItems = snapshot.data ?? [];

          if (_cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    final recipe = item['recipes'] as Map<String, dynamic>;
                    final quantity = item['quantity'] as int;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Recipe Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: recipe['image_url'] != null
                                    ? CachedNetworkImage(
                                        imageUrl: recipe['image_url'],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => const Icon(Icons.fastfood),
                                      )
                                    : const Icon(Icons.fastfood),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Recipe Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe['name'] ?? 'No name',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${recipe['time_to_make'] ?? '?'} min',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity Controls
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => _updateQuantity(item['id'], quantity - 1),
                                ),
                                Text(
                                  quantity.toString(),
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => _updateQuantity(item['id'], quantity + 1),
                                ),
                              ],
                            ),
                            // Remove button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(item['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildCheckoutBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckoutBar() {
  final totalItems = _cartItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: $totalItems items',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: _cartItems.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(cartItems: _cartItems),
                      ),
                    );
                  },
            child: Text(
              'Checkout',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}