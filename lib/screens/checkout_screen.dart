import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  
  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    return widget.cartItems.fold(0, (total, item) {
      return total + (item['quantity'] * (item['recipes']['price'] ?? 0));
    });
  }

  Future<String> _processOrder() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final orderResponse = await Supabase.instance.client
          .from('orders')
          .insert({
            'user_id': userId,
            'delivery_address': _addressController.text,
            'contact_number': _phoneController.text,
            'special_instructions': _notesController.text,
            'total_amount': _calculateTotal(),
            'status': 'pending',
          })
          .select('id');

      if (orderResponse.isEmpty) throw Exception('Order creation failed');
      
      final orderId = orderResponse[0]['id'] as String;
      if (orderId.isEmpty) throw Exception('Invalid order ID');

      final orderItems = widget.cartItems.map((item) => {
        'order_id': orderId,
        'recipe_id': item['recipes']['id'],
        'quantity': item['quantity'],
        'price': item['recipes']['price'] ?? 0,
      }).toList();

      await Supabase.instance.client.from('order_items').insert(orderItems);
      await Supabase.instance.client.from('cart').delete().eq('user_id', userId);

      return orderId;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order failed: ${e.toString()}')),
        );
      }
      rethrow;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final orderId = await _processOrder();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(orderId: orderId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successful but order failed: ${e.toString()}')),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${response.message ?? 'Unknown error'}')),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External wallet selected: ${response.walletName}')),
      );
    }
  }

  void _openRazorpayCheckout() {
    final options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // Test key - replace with your live key for production
      'amount': _calculateTotal() * 100, // Amount in paise
      'name': 'Food App',
      'description': 'Order Payment',
      'prefill': {
        'contact': _phoneController.text,
        'email': Supabase.instance.client.auth.currentUser?.email ?? '',
      },
      'theme': {'color': '#FF6B6B'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching payment: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    _openRazorpayCheckout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: GoogleFonts.poppins()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Information
              Text('Delivery Information', 
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              
              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              // Special Instructions
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Special Instructions (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              
              // Order Summary
              Text('Order Summary', 
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              
              // List of items
              ...widget.cartItems.map((item) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(item['recipes']['image_url'] ?? ''),
                ),
                title: Text(item['recipes']['name']),
                subtitle: Text('${item['quantity']} × \$${item['recipes']['price']?.toStringAsFixed(2) ?? '0.00'}'),
                trailing: Text('\$${(item['quantity'] * (item['recipes']['price'] ?? 0)).toStringAsFixed(2)}'),
              )).toList(),
              
              const Divider(),
              
              // Total
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:', style: GoogleFonts.poppins(fontSize: 16)),
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Pay with Razorpay Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('PAY WITH RAZORPAY', 
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}