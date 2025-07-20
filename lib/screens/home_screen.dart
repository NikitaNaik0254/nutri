import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import '../screens/food_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _profileFuture;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sample food items data
  final List<Map<String, dynamic>> trendingFoods = const [
    {
      'image': 'assets/images/popular-food1.png',
      'name': 'Avocado Toast',
      'isLiked': false,
    },
    {
      'image': 'assets/images/seasonal-food2.png',
      'name': 'Berry Smoothie',
      'isLiked': false,
    },
    {
      'image': 'assets/images/notification1.png',
      'name': 'Quinoa Salad',
      'isLiked': false,
    },
    {
      'image': 'assets/images/fooditem.jpg',
      'name': 'Veggie Wrap',
      'isLiked': false,
    },
  ];

  final List<Map<String, dynamic>> popularFoods = const [
    {
      'image': 'assets/images/trending-recipe2.png',
      'name': 'Chicken Pasta',
      'isLiked': false,
    },
    {
      'image': 'assets/images/seasonal-food2.png',
      'name': 'Fruit Salad',
      'isLiked': false,
    },
    {
      'image': 'assets/images/popular-food1.png',
      'name': 'Oatmeal Bowl',
      'isLiked': false,
    },
    {
      'image': 'assets/images/seasonal-food3.png',
      'name': 'Protein Shake',
      'isLiked': false,
    },
    {
      'image': 'assets/images/seasonal-food1.png',
      'name': 'Veg Burger',
      'isLiked': false,
    },
    {
      'image': 'assets/images/item.jpg',
      'name': 'Salmon Rice',
      'isLiked': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchUserProfile();
  }

  Future<Map<String, dynamic>> _fetchUserProfile() async {
    try {
      // Get the current user's ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // Fetch profile data from Supabase
      final response = await _supabase
          .from('profiles')
          .select('first_name, last_name, email')
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      // Return default values if there's an error
      return {
        'first_name': 'User',
        'last_name': '',
        'email': 'unknown@example.com'
      };
    }
  }

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
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final profileData = snapshot.data ?? {
              'first_name': 'User',
              'last_name': '',
              'email': 'unknown@example.com'
            };

            final fullName = '${profileData['first_name']} ${profileData['last_name']}';
            final email = profileData['email'] ?? '';

            return ListView(
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
                        fullName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email,
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
                  onTap: () async {
                    await _supabase.auth.signOut();
                    if (!mounted) return;
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  final firstName = snapshot.hasData 
                      ? snapshot.data!['first_name'] ?? 'User'
                      : 'User';
                  
                  return Text(
                    'Welcome, $firstName!',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
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