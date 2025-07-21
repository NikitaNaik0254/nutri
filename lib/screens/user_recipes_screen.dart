import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRecipesScreen extends StatefulWidget {
  const UserRecipesScreen({Key? key}) : super(key: key);

  @override
  State<UserRecipesScreen> createState() => _UserRecipesScreenState();
}

class _UserRecipesScreenState extends State<UserRecipesScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRecipes();
  }

  Future<void> _fetchUserRecipes() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final response = await _supabase
          .from('recipes')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _recipes = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recipes: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        backgroundColor: Colors.green.shade800,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipes.isEmpty
              ? Center(
                  child: Text(
                    'No recipes added yet',
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    return _buildRecipeCard(recipe);
                  },
                ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recipe['image_url'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              child: Image.network(
                recipe['image_url'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['name'] ?? 'No name',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (recipe['description'] != null)
                  Text(
                    recipe['description'],
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(recipe['category'] ?? 'No category'),
                      backgroundColor: Colors.green.shade100,
                    ),
                    Chip(
                      label: Text('${recipe['time_to_make'] ?? 'N/A'} mins'),
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}