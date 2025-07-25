import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> recentRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentRecipes();
  }

  Future<void> _fetchRecentRecipes() async {
    try {
      final response = await supabase
          .from('recipes')
          .select()
          .order('created_at', ascending: false)
          .limit(10); // Get 10 most recent recipes

      if (mounted) {
        setState(() {
          recentRecipes = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recipes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recently Added Recipes',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recentRecipes.isEmpty
              ? Center(
                  child: Text(
                    'No recent recipes found',
                    style: GoogleFonts.poppins(),
                  ),
                )
              : _buildNotificationList(),
    );
  }

  Widget _buildNotificationList() {
    // Group recipes by date
    final Map<String, List<Map<String, dynamic>>> groupedRecipes = {};

    for (final recipe in recentRecipes) {
      final createdAt = DateTime.parse(recipe['created_at']);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      String dateKey;
      if (createdAt.isAfter(today)) {
        dateKey = 'Today';
      } else if (createdAt.isAfter(yesterday)) {
        dateKey = 'Yesterday';
      } else {
        dateKey = DateFormat('MMMM d').format(createdAt);
      }

      groupedRecipes.putIfAbsent(dateKey, () => []).add(recipe);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedRecipes.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  entry.key,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: entry.value.map((recipe) {
                  return _buildNotificationCard(recipe);
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRecipeDetails(recipe),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: recipe['image_url'] != null
                    ? Image.network(
                        recipe['image_url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: const Icon(Icons.fastfood),
                          );
                        },
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Recipe',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe['name'] ?? 'No name',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecipeDetails(Map<String, dynamic> recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  recipe['name'] ?? 'Recipe',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (recipe['image_url'] != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe['image_url'],
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.fastfood)),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (recipe['description'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe['description'],
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              if (recipe['ingredients'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingredients',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe['ingredients'],
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              if (recipe['steps'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Steps',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe['steps'],
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              // Nutrition information
              Text(
                'Nutrition Information',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildNutritionInfo('Calories', recipe['calories']?.toString()),
                  _buildNutritionInfo('Protein', recipe['protein']?.toString()),
                  _buildNutritionInfo('Carbs', recipe['carbs']?.toString()),
                  _buildNutritionInfo('Fat', recipe['fat']?.toString()),
                  if (recipe['dietary'] != null)
                    _buildNutritionInfo('Dietary', recipe['dietary']),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionInfo(String label, String? value) {
    return Chip(
      label: Text(
        value != null ? '$label: $value' : label,
        style: GoogleFonts.poppins(),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}