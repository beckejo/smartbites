import 'package:flutter/material.dart';
import 'ingredient_detail_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final bool showNutritionFacts;  // New parameter

  const RecipeDetailScreen({
    Key? key, 
    required this.recipe, 
    this.showNutritionFacts = false  // Default to false
  }) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late String displayName;
  
  @override
  void initState() {
    super.initState();
    displayName = widget.recipe['name'] ?? widget.recipe['description'];
    
    // Add this code to show nutrition facts automatically
    if (widget.showNutritionFacts) {
      // Use a short delay to ensure the screen is fully built
      Future.delayed(Duration.zero, () {
        final nutritionSums = calculateNutritionFacts();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NutritionFactsScreen(
              recipeName: displayName,
              nutritionFacts: nutritionSums,
            ),
          ),
        );
      });
    }
  }
  
  Future<void> _editName() async {
    final TextEditingController nameController = TextEditingController(text: displayName);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Recipe Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Recipe Name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, nameController.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    
    if (result != null && result.isNotEmpty) {
      setState(() {
        displayName = result;
        widget.recipe['name'] = result;  // Update the actual recipe name
      });
    }
  }

  // This method calculates the summed nutrient values.
  Map<String, double> calculateNutritionFacts() {
    // Retrieve ingredients from the recipe. If not present, fallback to a single ingredient.
    final List ingredients = widget.recipe['ingredients'] ??
        [
          {
            'description': widget.recipe['name'] ?? widget.recipe['description'],
            'nutrients': widget.recipe['nutrients']
          }
        ];

    final Map<String, double> nutritionSums = {};
    double totalWeight = 0.0;

    for (var ingredient in ingredients) {
      final List nutrients = ingredient['nutrients'];
      // Add the ingredient weight to total
      final double grams = ingredient['grams'] as double? ?? 0.0;
      totalWeight += grams;
      
      for (var nutrient in nutrients) {
        final String nutrientName = nutrient['nutrientName'];
        final double value = nutrient['value'];
        nutritionSums[nutrientName] =
            (nutritionSums[nutrientName] ?? 0) + value;
      }
    }
    
    // Add the total weight to the nutrition facts
    nutritionSums['__totalWeight__'] = totalWeight;
    return nutritionSums;
  }

  @override
  Widget build(BuildContext context) {
    // Use recipe['ingredients'] if available.
    final List ingredients = widget.recipe['ingredients'] ??
        [
          {
            'description': widget.recipe['name'] ?? widget.recipe['description'],
            'nutrients': widget.recipe['nutrients']
          }
        ];

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _editName,
          child: Row(
            children: [
              Expanded(child: Text(displayName)),
              const Icon(Icons.edit, size: 16),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display a list of ingredient names.
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  final double grams = ingredient['grams'] as double? ?? 0.0;
                  
                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              IngredientDetailScreen(ingredient: ingredient),
                        ),
                      );
                      // Refresh the UI when returning from ingredient detail screen
                      setState(() {
                        // No need to update any variables since the ingredient object
                        // was modified in-place in the IngredientDetailScreen
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          // Ingredient name
                          Expanded(
                            child: Text(
                              ingredient['description'] ?? 'Unnamed ingredient',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          // Weight in grams (right aligned)
                          Text(
                            '${grams.toStringAsFixed(1)} g',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Button to view summed nutrition facts.
            ElevatedButton(
              onPressed: () {
                final nutritionSums = calculateNutritionFacts();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NutritionFactsScreen(
                      recipeName: displayName,
                      nutritionFacts: nutritionSums,
                    ),
                  ),
                );
              },
              child: Text('$displayName Nutrition Facts'),
            ),
          ],
        ),
      ),
    );
  }
}

class NutritionFactsScreen extends StatefulWidget {  // Change to StatefulWidget
  final String recipeName;
  final Map<String, double> nutritionFacts;

  const NutritionFactsScreen({
    Key? key,
    required this.recipeName,
    required this.nutritionFacts,
  }) : super(key: key);

  @override
  _NutritionFactsScreenState createState() => _NutritionFactsScreenState();
}

class _NutritionFactsScreenState extends State<NutritionFactsScreen> {
  late String displayName;
  
  @override
  void initState() {
    super.initState();
    displayName = widget.recipeName;
  }
  
  String _getTotalWeight() {
    // Extract and remove the special key for weight
    double totalWeight = widget.nutritionFacts.remove('__totalWeight__') ?? 0.0;
    return totalWeight.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    // Extract total weight first, before categorizing nutrients
    final String totalWeight = _getTotalWeight();
    
    // Group nutrients by category
    Map<String, Map<String, double>> categorizedNutrients = {
      'Energy': {},
      'Fats': {},
      'Carbohydrates': {},
      'Proteins': {},
      'Vitamins': {},
      'Minerals': {},
      'Other': {},
    };
    
    // Helper function to categorize nutrients
    void categorizeNutrient(String name, double value) {
      final lowerName = name.toLowerCase();
      
      if (lowerName.contains('energy') || lowerName.contains('calorie')) {
        categorizedNutrients['Energy']![name] = value;
      } else if (lowerName.contains('fat') || lowerName.contains('cholesterol') || lowerName.contains('fatty')) {
        categorizedNutrients['Fats']![name] = value;
      } else if (lowerName.contains('carb') || lowerName.contains('sugar') || lowerName.contains('fiber')) {
        categorizedNutrients['Carbohydrates']![name] = value;
      } else if (lowerName.contains('protein') || lowerName.contains('amino')) {
        categorizedNutrients['Proteins']![name] = value;
      } else if (lowerName.contains('vitamin')) {
        categorizedNutrients['Vitamins']![name] = value;
      } else if (lowerName.contains('calcium') || lowerName.contains('iron') || 
                lowerName.contains('zinc') || lowerName.contains('magnesium') || 
                lowerName.contains('sodium') || lowerName.contains('potassium')) {
        categorizedNutrients['Minerals']![name] = value;
      } else {
        categorizedNutrients['Other']![name] = value;
      }
    }
    
    // Categorize all nutrients
    widget.nutritionFacts.forEach(categorizeNutrient);

    return Scaffold(
      appBar: AppBar(
        title: Text('$displayName Recipe Facts'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Text(
                    'Recipe Facts',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                // Thick black divider
                Container(height: 8.0, color: Colors.black),
                
                // Replace the recipe name section with weight information (no edit button)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Entire Recipe: $totalWeight g',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                
                // Thin black divider
                Container(height: 1.0, color: Colors.black),
                
                // Display each category of nutrients
                _buildNutrientCategory('Energy', categorizedNutrients['Energy']!),
                _buildNutrientCategory('Total Fat', categorizedNutrients['Fats']!),
                _buildNutrientCategory('Total Carbohydrate', categorizedNutrients['Carbohydrates']!),
                _buildNutrientCategory('Protein', categorizedNutrients['Proteins']!),
                
                // Medium black divider
                Container(height: 4.0, color: Colors.black),
                
                _buildNutrientCategory('Vitamins', categorizedNutrients['Vitamins']!),
                _buildNutrientCategory('Minerals', categorizedNutrients['Minerals']!),
                _buildNutrientCategory('Other Nutrients', categorizedNutrients['Other']!),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNutrientCategory(String categoryName, Map<String, double> nutrients) {
    if (nutrients.isEmpty) {
      return Container(); // Don't show empty categories
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Text(
            categoryName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        
        // Nutrients in this category
        ...nutrients.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(entry.key)),
                Text(entry.value.toStringAsFixed(2)),
              ],
            ),
          );
        }).toList(),
        
        // Thin divider after each category
        Container(height: 1.0, color: Colors.black),
      ],
    );
  }
}
