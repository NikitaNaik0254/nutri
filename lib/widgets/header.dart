import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight, // Standard app bar height
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0), // Small horizontal padding
        child: Row(
          children: [
            // Left menu button with proper error handling
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                try {
                  Scaffold.of(context).openDrawer();
                } catch (e) {
                  debugPrint('Error opening drawer: $e');
                }
              },
              tooltip: 'Open menu', // Accessibility
              padding: EdgeInsets.zero, // Tighter padding
              constraints: const BoxConstraints(), // Remove default button sizing
            ),

            // Centered title with proper expansion
            Expanded(
              child: Center(
                child: Text(
                  'NutriNest',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),

            // Right-side balance (or replace with real icon when needed)
            const SizedBox(
              width: 48, // Matches IconButton default width
              height: 48, // Matches height for perfect balance
            ),
          ],
        ),
      ),
    );
  }
}