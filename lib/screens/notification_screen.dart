import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today Section
            _buildSection(
              title: 'Today',
              notifications: [
                _buildNotificationCard(
                  type: 'Recipe Recommendation',
                  message: 'American Veg Salad with fresh vegetables and dressing',
                  imagePath: 'assets/images/notification1.png',
                ),
                _buildNotificationCard(
                  type: 'Recipe Recommendation',
                  message: 'Healthy Taco Salad with lean ground beef and veggies',
                  imagePath: 'assets/images/notification2.png',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Yesterday Section
            _buildSection(
              title: 'Yesterday',
              notifications: [
                _buildNotificationCard(
                  type: 'Order',
                  message: 'Your order has been delivered successfully',
                  imagePath: 'assets/images/notification2.png',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Last Week Section
            _buildSection(
              title: 'Last Week',
              notifications: [
                _buildNotificationCard(
                  type: 'Recipe Recommendation',
                  message: 'Sprouts Salad with fresh sprouts and lemon dressing',
                  imagePath: 'assets/images/notification1.png',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> notifications,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: notifications,
        ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required String type,
    required String message,
    required String imagePath,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _truncateMessage(message, 4),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }

  String _truncateMessage(String message, int maxWords) {
    final words = message.split(' ');
    if (words.length <= maxWords) {
      return message;
    }
    return '${words.take(maxWords).join(' ')}...';
  }
}