import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/category_button.dart';
import '../widgets/food_card.dart';
import '../widgets/header.dart';
import '../screens/search_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';
import '../auth/login_screen.dart'; // Add this import

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Predefined credentials (same as in login_screen.dart)
  static const String validUsername = "NutriNest User";
  static const String validEmail = "user@nutrinest.com";
  static const String validPassword = "nutrinest123";

  @override
  Widget build(BuildContext context) {
    // List of image paths from your assets
    final List<String> trendingImages = [
      'assets/images/1.jpg',
      'assets/images/2.jpg',
      'assets/images/1.jpg',
      'assets/images/2.jpg',
      'assets/images/1.jpg',
    ];

    final List<String> popularImages = [
      'assets/images/1.jpg',
      'assets/images/2.jpg',
      'assets/images/1.jpg',
      'assets/images/2.jpg',
      'assets/images/1.jpg',
      'assets/images/2.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const HeaderWidget(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout and return to login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message with username
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Welcome, ${validUsername}!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Rest of your existing content...
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Trending Recipes',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: trendingImages.length,
                itemBuilder: (context, index) {
                  return FoodCard(
                    imageUrl: trendingImages[index],
                    title: 'Delicious Food ${index + 1}',
                    rating: 4.0 + (index * 0.1),
                  );
                },
              ),
            ),
            
            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Categories',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  CategoryButton(icon: Icons.cake, label: 'Dessert'),
                  SizedBox(width: 10),
                  CategoryButton(icon: Icons.fastfood, label: 'Snacks'),
                  SizedBox(width: 10),
                  CategoryButton(icon: Icons.restaurant, label: 'Meals'),
                  SizedBox(width: 10),
                  CategoryButton(icon: Icons.local_drink, label: 'Drinks'),
                ],
              ),
            ),
            
            // Popular Recipes Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Popular Recipes',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: List.generate(popularImages.length, (index) {
                return FoodCard(
                  imageUrl: popularImages[index],
                  title: 'Popular Food ${index + 1}',
                  rating: 4.5 + (index * 0.1),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) { // Search
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          } else if (index == 3) { // Notifications
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          } else if (index == 4) { // Profile
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}