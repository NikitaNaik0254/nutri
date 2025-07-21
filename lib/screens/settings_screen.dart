import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.green.shade800,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('Edit Profile', style: GoogleFonts.poppins()),
            onTap: () {
              // Navigate to edit profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text('Notification Settings', style: GoogleFonts.poppins()),
            onTap: () {
              // Navigate to notification settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text('Privacy & Security', style: GoogleFonts.poppins()),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text('Help & Support', style: GoogleFonts.poppins()),
            onTap: () {
              // Navigate to help screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', 
                style: GoogleFonts.poppins(color: Colors.red)),
            onTap: () async {
              await supabase.auth.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}