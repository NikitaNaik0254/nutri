import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<String> uploadRecipe({
    required String name,
    required String description,
    required List<Map<String, dynamic>> ingredients,
    required List<String> steps,
    required double protein,
    required double carbs,
    required double calories,
    required double fats,
    required String dietaryPreference,
    required String cookingTime,
    required String difficulty,
    required String cuisine,
    required String category,
    required String season,
    String? imagePath,
    String? videoPath,
    bool isDraft = false,
  }) async {
    try {
      // Insert recipe
      final recipeResponse = await Supabase.instance.client
          .from('recipes')
          .insert({
            'name': name,
            'description': description,
            'protein': protein,
            'carbs': carbs,
            'calories': calories,
            'fats': fats,
            'dietary_preferences': dietaryPreference,
            'cooking_time': cookingTime,
            'difficulty': difficulty,
            'cuisine': cuisine,
            'category': category,
            'season': season,
            'image_path': imagePath,
            'video_path': videoPath,
            'is_draft': isDraft,
          })
          .select()
          .single();

      final recipeId = recipeResponse['id'] as String;

      // Insert ingredients and steps...
      
      return recipeId; // Now matches the return type
    } catch (e) {
      throw Exception('Failed to upload recipe: $e');
    }
  }
static Future<String?> uploadMedia(String filePath, String fileName) async {
  try {
    final file = File(filePath); // 📂 Local file
    final fileExtension = fileName.split('.').last;
    final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    await Supabase.instance.client.storage
        .from('recipe-media')
        .upload(uniqueFileName, file); // ✅ Directly pass the File object

    final publicUrl = Supabase.instance.client.storage
        .from('recipe-media')
        .getPublicUrl(uniqueFileName);

    return publicUrl;
  } catch (e) {
    print('Error uploading media: $e');
    return null;
  }
}

}