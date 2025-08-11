import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/home_screen.dart';

class FoodPreferencesScreen extends StatefulWidget {
  const FoodPreferencesScreen({super.key});

  @override
  _FoodPreferencesScreenState createState() => _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState extends State<FoodPreferencesScreen> {
  final supabase = Supabase.instance.client;
  
  // Dietary preferences
  String? dietaryPreference;
  final List<String> dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Pescatarian',
    'Flexitarian',
    'Non-vegetarian',
    'Keto',
    'Meat'
    'Paleo',
  ];
  
  // Health preferences
  final Map<String, bool> healthPreferences = {
    'Gluten-free': false,
    'Dairy-free': false,
    'Nut-free': false,
    'Low-sodium': false,
    'Sugar-free': false,
    'Organic only': false,
  };
  
  // Food dislikes/allergies
  final Map<String, bool> foodAvoidances = {
    'Seafood': false,
    'Eggs': false,
    'Soy': false,
    'Wheat': false,
    'Shellfish': false,
    'Peanuts': false,
    'Tree nuts': false,
  };
  
  // Meal preferences
  String? mealFrequency;
  final List<String> frequencyOptions = ['3', '4', '5', '6+'];
  
  // Cooking preferences
  String? cookingTime;
  final List<String> timeOptions = [
    '<15 mins',
    '15-30 mins',
    '30-45 mins',
    '45+ mins'
  ];
  
  // Health goals
  String? primaryGoal;
  final List<String> goalOptions = [
    'Weight loss',
    'Weight gain',
    'Muscle building',
    'Maintenance',
    'Improve digestion',
    'Boost energy',
    'Manage condition'
  ];
  
  // Additional preferences
  bool prefersSprouts = false;
  bool prefersFermentedFoods = false;
  bool prefersWholeGrains = false;
  bool prefersLowCarb = false;
  bool prefersHighProtein = false;
  bool prefersHighFiber = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          dietaryPreference = response['dietary_preference'] as String?;
          primaryGoal = response['health_goals'] as String?;
          mealFrequency = response['meal_frequency'] as String?;
          cookingTime = response['cooking_time_preference'] as String?;
          prefersSprouts = response['prefers_sprouts'] as bool? ?? false;
          prefersFermentedFoods = response['prefers_fermented_foods'] as bool? ?? false;
          prefersWholeGrains = response['prefers_whole_grains'] as bool? ?? false;
          prefersLowCarb = response['prefers_low_carb'] as bool? ?? false;
          prefersHighProtein = response['prefers_high_protein'] as bool? ?? false;
          prefersHighFiber = response['prefers_high_fiber'] as bool? ?? false;
          
          // Update health preferences
          final healthPrefs = (response['health_preferences'] as List<dynamic>? ?? []);
          for (var pref in healthPrefs) {
            if (healthPreferences.containsKey(pref)) {
              healthPreferences[pref] = true;
            }
          }
          
          // Update food avoidances
          final avoidances = (response['food_avoidances'] as List<dynamic>? ?? []);
          for (var avoidance in avoidances) {
            if (foodAvoidances.containsKey(avoidance)) {
              foodAvoidances[avoidance] = true;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading preferences: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Preferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePreferences,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update your food preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Dietary Preference
            const Text('Primary dietary preference:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...dietaryOptions.map((option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: dietaryPreference,
              onChanged: (value) => setState(() => dietaryPreference = value),
            )).toList(),
            
            const Divider(),
            
            // Health Preferences
            const Text('Health preferences (select all that apply):', style: TextStyle(fontWeight: FontWeight.bold)),
            ...healthPreferences.keys.map((key) => CheckboxListTile(
              title: Text(key),
              value: healthPreferences[key],
              onChanged: (value) => setState(() => healthPreferences[key] = value!),
            )).toList(),
            
            const Divider(),
            
            // Foods to Avoid
            const Text('Foods to avoid (select all that apply):', style: TextStyle(fontWeight: FontWeight.bold)),
            ...foodAvoidances.keys.map((key) => CheckboxListTile(
              title: Text(key),
              value: foodAvoidances[key],
              onChanged: (value) => setState(() => foodAvoidances[key] = value!),
            )).toList(),
            
            const Divider(),
            
            // Meal Frequency
            const Text('Typical number of meals per day:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: mealFrequency,
              items: frequencyOptions.map((option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              )).toList(),
              onChanged: (value) => setState(() => mealFrequency = value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select meal frequency',
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Cooking Time
            const Text('Preferred cooking time per meal:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: cookingTime,
              items: timeOptions.map((option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              )).toList(),
              onChanged: (value) => setState(() => cookingTime = value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select cooking time',
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Health Goals
            const Text('Primary health goal:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: primaryGoal,
              items: goalOptions.map((option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              )).toList(),
              onChanged: (value) => setState(() => primaryGoal = value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select health goal',
              ),
            ),
            
            const Divider(),
            
            // Additional Preferences
            const Text('Additional preferences:', style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text('Prefer sprouts in diet'),
              value: prefersSprouts,
              onChanged: (value) => setState(() => prefersSprouts = value!),
            ),
            CheckboxListTile(
              title: const Text('Prefer fermented foods'),
              value: prefersFermentedFoods,
              onChanged: (value) => setState(() => prefersFermentedFoods = value!),
            ),
            CheckboxListTile(
              title: const Text('Prefer whole grains'),
              value: prefersWholeGrains,
              onChanged: (value) => setState(() => prefersWholeGrains = value!),
            ),
            CheckboxListTile(
              title: const Text('Prefer low-carb options'),
              value: prefersLowCarb,
              onChanged: (value) => setState(() => prefersLowCarb = value!),
            ),
            CheckboxListTile(
              title: const Text('Prefer high-protein foods'),
              value: prefersHighProtein,
              onChanged: (value) => setState(() => prefersHighProtein = value!),
            ),
            CheckboxListTile(
              title: const Text('Prefer high-fiber foods'),
              value: prefersHighFiber,
              onChanged: (value) => setState(() => prefersHighFiber = value!),
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Preferences'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _savePreferences() async {
    if (dietaryPreference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your dietary preference')),
      );
      return;
    }
    
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      final preferencesData = {
        'user_id': userId,
        'dietary_preference': dietaryPreference,
        'health_goals': primaryGoal,
        'meal_frequency': mealFrequency,
        'cooking_time_preference': cookingTime,
        'prefers_sprouts': prefersSprouts,
        'prefers_fermented_foods': prefersFermentedFoods,
        'prefers_whole_grains': prefersWholeGrains,
        'prefers_low_carb': prefersLowCarb,
        'prefers_high_protein': prefersHighProtein,
        'prefers_high_fiber': prefersHighFiber,
        'health_preferences': healthPreferences.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList(),
        'food_avoidances': foodAvoidances.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await supabase
        .from('user_preferences')
        .upsert(preferencesData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: ${e.toString()}')),
        );
      }
    }
  }
}