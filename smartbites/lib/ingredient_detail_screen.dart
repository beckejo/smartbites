import 'package:flutter/material.dart';

class IngredientDetailScreen extends StatefulWidget {  // Change to StatefulWidget
  final Map<String, dynamic> ingredient;

  const IngredientDetailScreen({super.key, required this.ingredient});

  @override
  _IngredientDetailScreenState createState() => _IngredientDetailScreenState();
}

class _IngredientDetailScreenState extends State<IngredientDetailScreen> {
  late String ingredientName;

  @override
  void initState() {
    super.initState();
    ingredientName = widget.ingredient['description'] ?? 'Unnamed ingredient';
  }

  Future<void> _editIngredientName() async {
    final TextEditingController nameController = TextEditingController(text: ingredientName);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Ingredient Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Ingredient Name',
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
        ingredientName = result;
        widget.ingredient['description'] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double grams = widget.ingredient['grams'] as double? ?? 0;
    final List<Map<String, dynamic>> nutrients =
        List<Map<String, dynamic>>.from(widget.ingredient['nutrients'] ?? []);
    
    // Group nutrients by category
    Map<String, List<Map<String, dynamic>>> categorizedNutrients = {
      'Energy': [],
      'Fats': [],
      'Carbohydrates': [],
      'Proteins': [],
      'Vitamins': [],
      'Minerals': [],
      'Other': [],
    };
    
    // Helper function to categorize nutrients
    void categorizeNutrient(Map<String, dynamic> nutrient) {
      final String name = nutrient['nutrientName'] as String;
      final lowerName = name.toLowerCase();
      
      if (lowerName.contains('energy') || lowerName.contains('calorie')) {
        categorizedNutrients['Energy']!.add(nutrient);
      } else if (lowerName.contains('fat') || lowerName.contains('cholesterol') || lowerName.contains('fatty')) {
        categorizedNutrients['Fats']!.add(nutrient);
      } else if (lowerName.contains('carb') || lowerName.contains('sugar') || lowerName.contains('fiber')) {
        categorizedNutrients['Carbohydrates']!.add(nutrient);
      } else if (lowerName.contains('protein') || lowerName.contains('amino')) {
        categorizedNutrients['Proteins']!.add(nutrient);
      } else if (lowerName.contains('vitamin')) {
        categorizedNutrients['Vitamins']!.add(nutrient);
      } else if (lowerName.contains('calcium') || lowerName.contains('iron') || 
                 lowerName.contains('zinc') || lowerName.contains('magnesium') || 
                 lowerName.contains('sodium') || lowerName.contains('potassium')) {
        categorizedNutrients['Minerals']!.add(nutrient);
      } else {
        categorizedNutrients['Other']!.add(nutrient);
      }
    }
    
    // Categorize all nutrients
    for (var nutrient in nutrients) {
      categorizeNutrient(nutrient);
    }

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: _editIngredientName,
          child: Row(
            children: [
              Expanded(
                child: Text(ingredientName),
              ),
              const Icon(Icons.edit, size: 16),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FDA-style Nutrition Facts label
              Container(
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
                        'Ingredient Facts',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Thick black divider
                    Container(height: 8.0, color: Colors.black),
                    
                    // Amount used section (without edit button)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Amount used: $grams g',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    // Thin black divider
                    Container(height: 1.0, color: Colors.black),
                    
                    // Display each category of nutrients
                    if (categorizedNutrients['Energy']!.isNotEmpty) _buildNutrientCategory('Energy', categorizedNutrients['Energy']!),
                    if (categorizedNutrients['Fats']!.isNotEmpty) _buildNutrientCategory('Total Fat', categorizedNutrients['Fats']!),
                    if (categorizedNutrients['Carbohydrates']!.isNotEmpty) _buildNutrientCategory('Total Carbohydrate', categorizedNutrients['Carbohydrates']!),
                    if (categorizedNutrients['Proteins']!.isNotEmpty) _buildNutrientCategory('Protein', categorizedNutrients['Proteins']!),
                    
                    // Medium black divider
                    Container(height: 4.0, color: Colors.black),
                    
                    if (categorizedNutrients['Vitamins']!.isNotEmpty) _buildNutrientCategory('Vitamins', categorizedNutrients['Vitamins']!),
                    if (categorizedNutrients['Minerals']!.isNotEmpty) _buildNutrientCategory('Minerals', categorizedNutrients['Minerals']!),
                    if (categorizedNutrients['Other']!.isNotEmpty) _buildNutrientCategory('Other Nutrients', categorizedNutrients['Other']!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNutrientCategory(String categoryName, List<Map<String, dynamic>> nutrients) {
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
        ...nutrients.map((nutrient) {
          final double value = nutrient['value'] as double;
          final String name = nutrient['nutrientName'] as String;
          final String unit = nutrient['unitName'] as String;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(name)) ,
                Text('${value.toStringAsFixed(2)} $unit'),
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
