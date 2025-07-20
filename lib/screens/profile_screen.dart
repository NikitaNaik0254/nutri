import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';
import '../screens/address_screen.dart';
import '../screens/food_preferences_screen.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  late Future<Map<String, dynamic>> _profileFuture;
  late Future<Map<String, dynamic>?> _addressFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
    _addressFuture = _fetchAddress();
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('profiles')
          .select('first_name, last_name, email')
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      return {
        'first_name': 'User',
        'last_name': '',
        'email': 'unknown@example.com'
      };
    }
  }

  Future<Map<String, dynamic>?> _fetchAddress() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('address')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade800.withOpacity(0.7),
              Colors.green.shade600.withOpacity(0.7),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Picture Section
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/images/user.jpg'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.green.shade800,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // User Name with Edit Button
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _profileFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    
                    final firstName = snapshot.data?['first_name'] ?? 'User';
                    final lastName = snapshot.data?['last_name'] ?? '';
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$firstName $lastName',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                          onPressed: () {
                            // Add name edit functionality here
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              // Email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _profileFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    
                    final email = snapshot.data?['email'] ?? 'unknown@example.com';
                    
                    return Text(
                      email,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    );
                  },
                ),
              ),
              
              // Main Content Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile Options Section
                    Column(
                      children: [
                        FutureBuilder<Map<String, dynamic>?>(
                          future: _addressFuture,
                          builder: (context, snapshot) {
                            final hasAddress = snapshot.data != null;
                            return _buildProfileOption(
                              title: 'Address',
                              subtitle: hasAddress 
                                  ? '${snapshot.data?['house_number']}, ${snapshot.data?['street']}'
                                  : 'Add your address',
                              icon: Icons.location_on,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddressScreen(),
                                  ),
                                ).then((_) {
                                  setState(() {
                                    _addressFuture = _fetchAddress();
                                  });
                                });
                              },
                            );
                          },
                        ),
                         _buildProfileOption(
                          title: 'Favorite Order',
                          icon: Icons.favorite,
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          title: 'My Order',
                          icon: Icons.shopping_bag,
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          title: 'My Preferences',
                          icon: Icons.restaurant,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FoodPreferencesScreen(),
                              ),
                            ).then((_) {
                              // Refresh profile data when returning from preferences
                              setState(() {
                                _profileFuture = _fetchProfile();
                              });
                            });
                          },
                        ),
                        _buildProfileOption(
                          title: 'Settings',
                          icon: Icons.settings,
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          title: 'Notification',
                          icon: Icons.notifications,
                          onTap: () {},
                        ),
                      ],
                    ),
                    
                    const Divider(height: 1, thickness: 1),
                    
                    // Log Out Button
                    _buildProfileOption(
                      title: 'Log Out',
                      icon: Icons.logout,
                      textColor: Colors.red,
                      onTap: () async {
                        await _supabase.auth.signOut();
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    String? subtitle,
    bool isSelected = false,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isSelected ? Colors.green.shade800 : Colors.grey[600],
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? (isSelected ? Colors.blue.shade800 : Colors.black),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey,
              ),
            )
          : null,
      trailing: isSelected
          ? Icon(Icons.check, color: Colors.green.shade800)
          : Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}