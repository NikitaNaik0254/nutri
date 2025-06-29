import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/category_button.dart';
import '../widgets/food_card.dart';
import '../widgets/header.dart';
import '../screens/search_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/cart_screen.dart';
import '../auth/login_screen.dart';
import '../screens/chatbot_screen.dart';
import '../screens/meal_planner_screen.dart';
import '../screens/food_detail_screen.dart'; // You'll need to create this

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Predefined credentials
  static const String validUsername = "NutriNest User";
  static const String validEmail = "user@nutrinest.com";
  static const String validPassword = "nutrinest123";

  // Sample food items data
  final List<Map<String, dynamic>> trendingFoods = const [
    {
      'image': 'assets/images/1.jpg',
      'name': 'Avocado Toast',
      'isLiked': false,
    },
    {
      'image': 'assets/images/2.jpg',
      'name': 'Berry Smoothie',
      'isLiked': false,
    },
    {
      'image': 'assets/images/1.jpg',
      'name': 'Quinoa Salad',
      'isLiked': false,
    },
    {
      'image': 'assets/images/2.jpg',
      'name': 'Veggie Wrap',
      'isLiked': false,
    },
  ];

  final List<Map<String, dynamic>> popularFoods = const [
    {
      'image': 'assets/images/1.jpg',
      'name': 'Chicken Pasta',
      'isLiked': false,
    },
    {
      'image': 'assets/images/2.jpg',
      'name': 'Fruit Salad',
      'isLiked': false,
    },
    {
      'image': 'assets/images/1.jpg',
      'name': 'Oatmeal Bowl',
      'isLiked': false,
    },
    {
      'image': 'assets/images/2.jpg',
      'name': 'Protein Shake',
      'isLiked': false,
    },
    {
      'image': 'assets/images/1.jpg',
      'name': 'Veg Burger',
      'isLiked': false,
    },
    {
      'image': 'assets/images/2.jpg',
      'name': 'Salmon Rice',
      'isLiked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const HeaderWidget(),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.7,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    validUsername,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    validEmail,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text('Home', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: Text('Search', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: Text('Chatbot', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatbotScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('Meal Planner', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MealPlannerScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text('Notifications', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text('Logout', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                itemCount: trendingFoods.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailScreen(
                            foodItem: trendingFoods[index],
                          ),
                        ),
                      );
                    },
                    child: FoodCard(
                      imageUrl: trendingFoods[index]['image'],
                      title: trendingFoods[index]['name'],
                      isLiked: trendingFoods[index]['isLiked'],
                      onLikePressed: () {
                        // Handle like button press
                      },
                      onAddPressed: () {
                        // Handle add to cart button press
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${trendingFoods[index]['name']} added to cart'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
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
              children: List.generate(popularFoods.length, (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodDetailScreen(
                          foodItem: popularFoods[index],
                        ),
                      ),
                    );
                  },
                  child: FoodCard(
                    imageUrl: popularFoods[index]['image'],
                    title: popularFoods[index]['name'],
                    isLiked: popularFoods[index]['isLiked'],
                    onLikePressed: () {
                      // Handle like button press
                    },
                    onAddPressed: () {
                      // Handle add to cart button press
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${popularFoods[index]['name']} added to cart'),
                        ),
                      );
                    },
                  ),
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
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          } else if (index == 4) {
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