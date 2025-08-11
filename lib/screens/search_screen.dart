import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final supabase = Supabase.instance.client;
  String selectedCategory = 'All';
  String searchQuery = '';
  final List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Desserts'
  ];
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes({String? category}) async {
    try {
      setState(() {
        isLoading = true;
      });

      final query = supabase.from('recipes').select();

      if (category != null && category != 'All') {
        query.eq('category', category);
      }

      if (searchQuery.isNotEmpty) {
        query.ilike('name', '%$searchQuery%');
      }

      final response = await query.order('created_at', ascending: false);

      setState(() {
        recipes = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
          'Search Recipes',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Search Bar with Filter Button
            _buildSearchBar(),
            const SizedBox(height: 16),
            
            // Categories Chips
            _buildCategoryChips(),
            const SizedBox(height: 16),
            
            // Recipes Grid
            _buildRecipesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search recipes...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  isSearching = value.isNotEmpty;
                });
                _fetchRecipes(category: selectedCategory != 'All' ? selectedCategory : null);
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            _showFilterModal(context);
          },
          icon: const Icon(Icons.tune, size: 30),
          style: IconButton.styleFrom(
            backgroundColor: Colors.green[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = selected ? category : 'All';
                });
                _fetchRecipes(category: selectedCategory != 'All' ? selectedCategory : null);
              },
              selectedColor: Colors.green[800],
              labelStyle: GoogleFonts.poppins(
                color: selectedCategory == category ? Colors.white : Colors.black,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecipesGrid() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recipes.isEmpty) {
      return Center(
        child: Text(
          isSearching
              ? 'No recipes found for "$searchQuery"'
              : selectedCategory != 'All'
                  ? 'No $selectedCategory recipes available'
                  : 'No recipes available',
          style: GoogleFonts.poppins(),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return _buildRecipeCard(recipes[index]);
      },
    );
  }

 Widget _buildRecipeCard(Map<String, dynamic> recipe) {
  return GestureDetector(
    onTap: () => _showRecipeDetails(recipe),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: recipe['image_url'] != null
                ? Image.network(
                    recipe['image_url'].toString(),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.fastfood)),
                      );
                    },
                  )
                : Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.fastfood)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['name']?.toString() ?? 'No name',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (recipe['id'] != null) {
                              _toggleLike(recipe['id'].toString());
                            }
                          },
                          icon: Icon(
                            (recipe['is_liked'] as bool?) == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: (recipe['is_liked'] as bool?) == true
                                ? Colors.red
                                : Colors.grey,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          onPressed: () {
                            if (recipe['id'] != null) {
                              _addToCart(recipe['id'].toString());
                            }
                          },
                          icon: const Icon(
                            Icons.shopping_cart,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    if (recipe['calories'] != null)
                      Text(
                        '${recipe['calories']} cal',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildFilterModalContent();
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildFilterModalContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Filter',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Categories Section
          Text(
            'Categories',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = selected ? category : 'All';
                  });
                },
                selectedColor: Colors.green[800],
                labelStyle: GoogleFonts.poppins(
                  color: selectedCategory == category ? Colors.white : Colors.black,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // Recipe Type Section
          Text(
            'Recipe Type',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Veg', 'Non-Veg', 'Vegan'].map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: false,
                onSelected: (selected) {
                  // You can implement type filtering here
                },
                selectedColor: Colors.green[800],
                labelStyle: GoogleFonts.poppins(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // Apply Filter Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _fetchRecipes(category: selectedCategory != 'All' ? selectedCategory : null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Apply Filter',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Clear Button
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  selectedCategory = 'All';
                  searchQuery = '';
                });
                Navigator.pop(context);
                _fetchRecipes();
              },
              child: Text(
                'Clear',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.green[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _toggleLike(String recipeId) async {
    try {
      // Implement your like logic here
      // This might involve updating the recipe in Supabase
      // or managing a separate 'likes' table
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Like functionality will be implemented')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling like: $e')),
      );
    }
  }

  Future<void> _addToCart(String recipeId) async {
    try {
      // Implement your cart logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add to cart functionality will be implemented')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: $e')),
      );
    }
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