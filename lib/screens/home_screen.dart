import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/category_button.dart';
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
  final SupabaseClient _supabase = Supabase.instance.client;
  late Future<Map<String, dynamic>> _profileFuture;
  late Future<List<Map<String, dynamic>>> _trendingRecipesFuture;
  late Future<List<Map<String, dynamic>>> _popularRecipesFuture;
  late Future<List<Map<String, dynamic>>> _breakfastRecipesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _profileFuture = _fetchUserProfile();
    _trendingRecipesFuture = _fetchRecipesByCategory('Dinner');
    _popularRecipesFuture = _fetchRecipesByCategory('Lunch');
    _breakfastRecipesFuture = _fetchRecipesByCategory('Breakfast');
  }

  Future<Map<String, dynamic>> _fetchUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('profiles')
          .select('first_name, last_name, email, profile_picture_url')
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return {
        'first_name': 'User',
        'last_name': '',
        'email': 'unknown@example.com',
        'profile_picture_url': null,
      };
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRecipesByCategory(String category) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select('''
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
          ''')
          .ilike('category', category)
          .order('created_at', ascending: false)
          .limit(6);

      if (response.isEmpty) throw Exception('No $category recipes found');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching $category recipes: $e');
      return [];
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });
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
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeMessage(),
              _buildRecipeSection('Trending Recipes', _trendingRecipesFuture, isHorizontal: true),
              _buildCategoriesSection(),
              _buildRecipeSection('Popular Recipes', _breakfastRecipesFuture),
              _buildRecipeSection('Seasonal Recipes', _popularRecipesFuture),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildRecipeSection(String title, Future<List<Map<String, dynamic>>> recipesFuture, 
      {bool isHorizontal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: isHorizontal ? 240 : null,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: recipesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              final recipes = snapshot.data ?? [];
              
              if (recipes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No recipes found',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                );
              }
              
              return isHorizontal
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        return _buildRecipeCard(recipes[index]);
                      },
                    )
                  : GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: recipes.map((recipe) => _buildRecipeCard(recipe)).toList(),
                    );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(foodItem: recipe),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.all(8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: _buildRecipeImage(recipe['image_url']),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['name'] ?? 'No name',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe['time_to_make'] ?? '?'} min',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 20),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${recipe['name']} added to cart')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.fastfood, size: 40, color: Colors.grey)),
      );
    }
    
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    );
  }

Widget _buildCategoriesSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
          children: [
            _buildComingSoonCategoryButton(Icons.cake, 'Dessert'),
            const SizedBox(width: 10),
            _buildComingSoonCategoryButton(Icons.fastfood, 'Snacks'),
            const SizedBox(width: 10),
            _buildComingSoonCategoryButton(Icons.restaurant, 'Meals'),
            const SizedBox(width: 10),
            _buildComingSoonCategoryButton(Icons.local_drink, 'Drinks'),
            const SizedBox(width: 10),
            _buildComingSoonCategoryButton(Icons.health_and_safety, 'Healthy'),
          ],
        ),
      ),
    ],
  );
}

Widget _buildComingSoonCategoryButton(IconData icon, String label) {
  return GestureDetector(
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coming Soon!'),
          duration: Duration(seconds: 1),
        ),
      );
    },
    child: CategoryButton(
      icon: icon,
      label: label,
    ),
  );
}

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
        } else if (index == 4) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
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
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
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
            'email': 'unknown@example.com',
            'profile_picture_url': null,
          };

          final fullName = '${profileData['first_name']} ${profileData['last_name']}';
          final email = profileData['email'] ?? '';
          final profilePicUrl = profileData['profile_picture_url'];

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
                    CircleAvatar(
                      radius: 30,
                      child: profilePicUrl != null
                          ? CachedNetworkImage(
                              imageUrl: profilePicUrl,
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.person),
                            )
                          : const Icon(Icons.person),
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
              _buildDrawerItem(Icons.home, 'Home', () => Navigator.pop(context)),
              _buildDrawerItem(Icons.search, 'Search', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
              }),
              _buildDrawerItem(Icons.chat, 'Chatbot', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen()));
              }),
              _buildDrawerItem(Icons.calendar_today, 'Meal Planner', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MealPlannerScreen()));
              }),
              _buildDrawerItem(Icons.notifications, 'Notifications', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
              }),
              const Divider(),
              _buildDrawerItem(Icons.logout, 'Logout', () async {
                await _supabase.auth.signOut();
                if (!mounted) return;
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: onTap,
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
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
    );
  }
}