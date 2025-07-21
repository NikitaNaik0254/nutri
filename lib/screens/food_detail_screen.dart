import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodDetailScreen extends StatelessWidget {
  final Map<String, dynamic> foodItem;

  const FoodDetailScreen({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(foodItem['name'] ?? 'Recipe Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            SizedBox(
              height: 250,
              width: double.infinity,
              child: foodItem['image_url'] != null && foodItem['image_url'].isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: foodItem['image_url'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.fastfood, size: 50, color: Colors.grey),
                      ),
                    ),
            ),
            
            // Recipe Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Name
                  Text(
                    foodItem['name'] ?? 'No name',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Cooking Time
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${foodItem['time_to_make'] ?? '?'} minutes',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Nutrition Information
                  _buildNutritionInfo(),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  if (foodItem['description'] != null && foodItem['description'].isNotEmpty)
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
                          foodItem['description'],
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  
                  // Ingredients (placeholder - you'll need to add this to your recipe data)
                  Text(
                    'Ingredients',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Ingredient 1\n• Ingredient 2\n• Ingredient 3\n• Ingredient 4',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Instructions (placeholder - you'll need to add this to your recipe data)
                  Text(
                    'Instructions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Step one instruction\n2. Step two instruction\n3. Step three instruction',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Add to Cart Button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${foodItem['name']} added to cart'),
                          ),
                        );
                      },
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNutritionItem('Calories', '${foodItem['calories'] ?? '?'}'),
            _buildNutritionItem('Protein', '${foodItem['protein'] ?? '?'}g'),
            _buildNutritionItem('Carbs', '${foodItem['carbs'] ?? '?'}g'),
            _buildNutritionItem('Fat', '${foodItem['fat'] ?? '?'}g'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}