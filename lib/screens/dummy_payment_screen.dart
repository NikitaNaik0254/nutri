import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DummyPaymentScreen extends StatelessWidget {
  final double amount;
  final Function() onPaymentSuccess;

  const DummyPaymentScreen({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment', style: GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('DEMO PAYMENT GATEWAY', 
                         style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text('Amount to Pay:', style: GoogleFonts.poppins()),
                    Text('\$${amount.toStringAsFixed(2)}', 
                         style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    _buildPaymentMethod('Credit Card', Icons.credit_card),
                    _buildPaymentMethod('PayPal', Icons.payment),
                    _buildPaymentMethod('Google Pay', Icons.account_balance_wallet),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  // Show processing dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text('Processing payment...'),
                        ],
                      ),
                    ),
                  );

                  // Simulate payment processing delay
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pop(context); // Close the dialog
                    onPaymentSuccess(); // Proceed with order confirmation
                  });
                },
                child: Text('PAY NOW', 
                     style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String name, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name, style: GoogleFonts.poppins()),
      trailing: const Icon(Icons.radio_button_checked, color: Colors.green),
    );
  }
}