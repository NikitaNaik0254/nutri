import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        backgroundColor: Colors.blue.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800.withOpacity(0.7),
              Colors.blue.shade600.withOpacity(0.7),
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
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(247, 247, 247, 247),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: () {
                            // Add edit functionality here
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // User Name with Edit Button
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pooja Kedia',
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
                ),
              ),
              
              // Address
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Text(
                  '76, Muripura scheme...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
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
                    // Payment Methods Section
                    Column(
                      children: [
                        _buildProfileOption(
                          title: 'Address',
                          icon: Icons.location_on,
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          title: 'Favorite Order',
                          icon: Icons.favorite,
                          isSelected: true,
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          title: 'My Order',
                          icon: Icons.shopping_bag,
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          title: 'Language',
                          icon: Icons.language,
                          onTap: () {},
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
                      onTap: () {
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
    bool isSelected = false,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isSelected ? Colors.blue.shade800 : Colors.grey[600],
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? (isSelected ? Colors.blue.shade800 : Colors.black),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Colors.blue.shade800)
          : Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}