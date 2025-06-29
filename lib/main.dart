import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './screens/home_screen.dart';
import './auth/login_screen.dart';
import './auth/register_screen.dart';
import './screens/nutri_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with direct values
  await Supabase.initialize(
    url: 'https://wqmxzkxidttwjihlmipf.supabase.co', // Replace with your actual URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndxbXh6a3hpZHR0d2ppaGxtaXBmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4NzI3NDgsImV4cCI6MjA2NjQ0ODc0OH0.YvWJffct53iGGoM4FbTPxk3tFgELFrjv1lGa9NjMnmE', // Replace with your actual anon key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green[600],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/nutri': (context) => const NutriHomeScreen(),
      },
    );
  }
}