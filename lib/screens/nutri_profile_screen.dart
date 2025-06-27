import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NutriProfileScreen extends StatelessWidget {
  const NutriProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutritionist Profile'),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            if (user != null) ...[
              Text(
                user.email ?? 'No email',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Professional Nutritionist',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 30),
            // Nutritionist-specific features
            ListTile(
              leading: const Icon(Icons.work_outline),
              title: Text(
                'Professional Information',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                // Navigate to professional info
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: Text(
                'My Recipes',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                // Navigate to nutritionist's recipes
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(
                'Account Settings',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                // Navigate to settings
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(),
              ),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}