import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
  final _picker = ImagePicker();
  late Future<Map<String, dynamic>> _profileFuture;
  late Future<Map<String, dynamic>?> _addressFuture;
  bool _isUploading = false;

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
          .select('first_name, last_name, email, profile_picture_url')
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      return {
        'first_name': 'User',
        'last_name': '',
        'email': 'unknown@example.com',
        'profile_picture_url': null,
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

  Future<void> _updateProfilePicture() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      // Read image bytes
      final fileBytes = await pickedFile.readAsBytes();
      if (fileBytes.isEmpty) throw Exception('Empty image file');

      // Determine file extension
      String fileExtension = 'jpg'; // default
      if (!kIsWeb) {
        final filePath = pickedFile.path.toLowerCase();
        fileExtension = filePath.split('.').last;
      } else {
        final mimeType = pickedFile.mimeType?.toLowerCase() ?? 'image/jpeg';
        if (mimeType.contains('jpeg')) {
          fileExtension = 'jpg';
        } else if (mimeType.contains('png')) {
          fileExtension = 'png';
        } else if (mimeType.contains('gif')) {
          fileExtension = 'gif';
        } else if (mimeType.contains('webp')) {
          fileExtension = 'webp';
        }
      }

      // Generate unique filename
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = '$userId/$fileName';

      // Upload to storage
      await _supabase.storage
          .from('profilepictures')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExtension',
              upsert: true,
            ),
          );

      // Get public URL
      final imageUrl = _supabase.storage
          .from('profilepictures')
          .getPublicUrl(filePath);

      // Update profile with new image URL
      await _supabase
          .from('profiles')
          .update({'profile_picture_url': imageUrl})
          .eq('id', userId);

      // Refresh profile data
      setState(() {
        _profileFuture = _fetchProfile();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile picture: ${e.toString()}')));
    } finally {
      setState(() => _isUploading = false);
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
        title: Center(
          child: Text(
            'Profile',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.green.shade800,
        actions: const [SizedBox(width: 48)], // To center the title
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
                    FutureBuilder<Map<String, dynamic>>(
                      future: _profileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        final imageUrl = snapshot.data?['profile_picture_url'];
                        
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: imageUrl != null
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.green,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                    if (!_isUploading)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _updateProfilePicture,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.green.shade800,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    if (_isUploading)
                      const Positioned.fill(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
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