import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:universal_html/html.dart' as html;

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({Key? key}) : super(key: key);

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String? _selectedCategory;
  String? _selectedDietary;
  String? _selectedDifficulty;
  String? _selectedSeason;
  String? _selectedCuisine;

  final List<String> categories = ['Breakfast', 'Lunch', 'Dinner'];
  final List<String> dietaryOptions = ['Vegan', 'Vegetarian', 'Dairy Free'];
  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> seasons = ['Summer', 'Rainy', 'Winter'];
  final List<String> cuisines = ['Indian', 'Italian', 'Mexican', 'Thai'];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        final blob = html.Blob([bytes]);
        final imageUrl = html.Url.createObjectUrlFromBlob(blob);
        setState(() {
          _imageUrl = imageUrl;
          _image = null;
        });
      } else {
        setState(() {
          _image = File(pickedFile.path);
          _imageUrl = null;
        });
      }
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    if ((!kIsWeb && _image == null) || (kIsWeb && _imageUrl == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    // Check for current user
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      Uint8List imageBytes;
      String imageExtension;

      if (kIsWeb) {
        final blobUri = _imageUrl!;
        final response = await html.HttpRequest.request(
          blobUri,
          responseType: 'arraybuffer',
        );
        imageBytes = Uint8List.view((response.response as ByteBuffer));
        imageExtension = '.jpg';
      } else {
        imageBytes = await _image!.readAsBytes();
        imageExtension = path.extension(_image!.path);
      }

      final imageName = '${DateTime.now().millisecondsSinceEpoch}$imageExtension';

      // Upload
      await _supabase.storage
          .from('recipe-images')
          .uploadBinary(imageName, imageBytes);

      final imageUrl = _supabase.storage
          .from('recipe-images')
          .getPublicUrl(imageName);

      // Insert record
      await _supabase.from('recipes').insert({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'ingredients': _ingredientsController.text.trim(),
        'steps': _stepsController.text.trim(),
        'protein': double.tryParse(_proteinController.text) ?? 0.0,
        'calories': double.tryParse(_caloriesController.text) ?? 0.0,
        'carbs': double.tryParse(_carbsController.text) ?? 0.0,
        'fat': double.tryParse(_fatController.text) ?? 0.0,
        'time_to_make': _timeController.text.trim(),
        'category': _selectedCategory,
        'dietary': _selectedDietary,
        'difficulty': _selectedDifficulty,
        'season': _selectedSeason,
        'cuisine': _selectedCuisine,
        'image_url': imageUrl,
        'user_id': currentUser.id,             // ← link recipe to this user
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _proteinController.dispose();
    _caloriesController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _timeController.dispose();
    if (kIsWeb && _imageUrl != null) {
      html.Url.revokeObjectUrl(_imageUrl!);
    }
    super.dispose();
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          isNumber ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        labelStyle: GoogleFonts.poppins(),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        labelStyle: GoogleFonts.poppins(),
      ),
      value: selectedValue,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Select $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Recipe'),
        backgroundColor: Colors.green.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Create a New Recipe',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),

                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade800),
                        ),
                        child: _image == null && _imageUrl == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 40, color: Colors.green.shade800),
                                  const SizedBox(height: 8),
                                  Text('Add Photo',
                                      style: GoogleFonts.poppins(
                                          color: Colors.green.shade800)),
                                ],
                              )
                            : kIsWeb
                                ? Image.network(_imageUrl!,
                                    fit: BoxFit.cover, width: 150, height: 150)
                                : Image.file(_image!,
                                    fit: BoxFit.cover, width: 150, height: 150),
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildTextField(_nameController, 'Recipe Name*'),
                    const SizedBox(height: 15),
                    _buildTextField(_descriptionController, 'Description'),
                    const SizedBox(height: 15),
                    _buildTextField(_ingredientsController, 'Ingredients'),
                    const SizedBox(height: 15),
                    _buildTextField(_stepsController, 'Steps to Make'),
                    const SizedBox(height: 15),
                    _buildTextField(_timeController, 'Time to Make'),
                    const SizedBox(height: 15),
                    _buildTextField(_proteinController, 'Protein (g)', isNumber: true),
                    const SizedBox(height: 15),
                    _buildTextField(_caloriesController, 'Calories', isNumber: true),
                    const SizedBox(height: 15),
                    _buildTextField(_carbsController, 'Carbs (g)', isNumber: true),
                    const SizedBox(height: 15),
                    _buildTextField(_fatController, 'Fat (g)', isNumber: true),

                    const SizedBox(height: 15),
                    _buildDropdown(
                      'Category',
                      categories,
                      _selectedCategory,
                      (val) => setState(() => _selectedCategory = val),
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      'Dietary',
                      dietaryOptions,
                      _selectedDietary,
                      (val) => setState(() => _selectedDietary = val),
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      'Difficulty',
                      difficulties,
                      _selectedDifficulty,
                      (val) => setState(() => _selectedDifficulty = val),
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      'Season',
                      seasons,
                      _selectedSeason,
                      (val) => setState(() => _selectedSeason = val),
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      'Cuisine',
                      cuisines,
                      _selectedCuisine,
                      (val) => setState(() => _selectedCuisine = val),
                    ),

                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveRecipe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Save Recipe',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}