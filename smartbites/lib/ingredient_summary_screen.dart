import 'package:flutter/material.dart';

class IngredientSummaryScreen extends StatefulWidget {
  final String description;
  final List<Map<String, dynamic>> nutrients;
  final double grams;

  const IngredientSummaryScreen({
    super.key,
    required this.description,
    required this.nutrients,
    required this.grams,
  });

  @override
  _IngredientSummaryScreenState createState() => _IngredientSummaryScreenState();
}

class _IngredientSummaryScreenState extends State<IngredientSummaryScreen> {
  late String _description;

  @override
  void initState() {
    super.initState();
    _description = widget.description;
  }

  void _showRenameDialog() {
    final TextEditingController controller = TextEditingController(text: _description);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Ingredient'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Ingredient Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _description = controller.text;
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
    for (var nutrient in widget.nutrients) {
      categorizeNutrient(nutrient);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ingredient name with edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _showRenameDialog,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _description,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.edit, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
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
                          'Ingredient Facts',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Thick black divider
                      Container(height: 8.0, color: Colors.black),
                      
                      // Replace serving size with amount used
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: _showRenameDialog,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Amount used: ${widget.grams} g',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.edit, size: 16),
                            ],
                          ),
                        ),
                      ),
                      
                      // Thin black divider
                      Container(height: 1.0, color: Colors.black),
                      
                      // Display each category of nutrients
                      if (categorizedNutrients['Energy']!.isNotEmpty) 
                        _buildNutrientCategory('Energy', categorizedNutrients['Energy']!),
                      if (categorizedNutrients['Fats']!.isNotEmpty) 
                        _buildNutrientCategory('Total Fat', categorizedNutrients['Fats']!),
                      if (categorizedNutrients['Carbohydrates']!.isNotEmpty) 
                        _buildNutrientCategory('Total Carbohydrate', categorizedNutrients['Carbohydrates']!),
                      if (categorizedNutrients['Proteins']!.isNotEmpty) 
                        _buildNutrientCategory('Protein', categorizedNutrients['Proteins']!),
                      
                      // Medium black divider
                      Container(height: 4.0, color: Colors.black),
                      
                      if (categorizedNutrients['Vitamins']!.isNotEmpty) 
                        _buildNutrientCategory('Vitamins', categorizedNutrients['Vitamins']!),
                      if (categorizedNutrients['Minerals']!.isNotEmpty) 
                        _buildNutrientCategory('Minerals', categorizedNutrients['Minerals']!),
                      if (categorizedNutrients['Other']!.isNotEmpty) 
                        _buildNutrientCategory('Other Nutrients', categorizedNutrients['Other']!),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'description': _description,
                        'nutrients': widget.nutrients,
                        'grams': widget.grams,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Add Ingredient'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
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
                Expanded(child: Text(name)),
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
