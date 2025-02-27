import 'package:flutter/material.dart';
import 'ingredient_detail_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  // This method calculates the summed nutrient values.
  Map<String, double> calculateNutritionFacts() {
    // Retrieve ingredients from the recipe. If not present, fallback to a single ingredient.
    final List ingredients = recipe['ingredients'] ??
        [
          {
            'description': recipe['name'] ?? recipe['description'],
            'nutrients': recipe['nutrients']
          }
        ];

    final Map<String, double> nutritionSums = {};

    for (var ingredient in ingredients) {
      final List nutrients = ingredient['nutrients'];
      for (var nutrient in nutrients) {
        final String nutrientName = nutrient['nutrientName'];
        final double value = nutrient['value'];
        nutritionSums[nutrientName] =
            (nutritionSums[nutrientName] ?? 0) + value;
      }
    }
    return nutritionSums;
  }

  @override
  Widget build(BuildContext context) {
    // Use recipe['ingredients'] if available.
    final List ingredients = recipe['ingredients'] ??
        [
          {
            'description': recipe['name'] ?? recipe['description'],
            'nutrients': recipe['nutrients']
          }
        ];

    final String titleText = recipe['name'] ?? recipe['description'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
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
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  return ListTile(
                    title:
                        Text(ingredient['description'] ?? 'Unnamed ingredient'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              IngredientDetailScreen(ingredient: ingredient),
                        ),
                      );
                    },
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
                      recipeName: titleText,
                      nutritionFacts: nutritionSums,
                    ),
                  ),
                );
              },
              child: Text('$titleText Nutrition Facts'),
            ),
          ],
        ),
      ),
    );
  }
}

class NutritionFactsScreen extends StatelessWidget {
  final String recipeName;
  final Map<String, double> nutritionFacts;

  const NutritionFactsScreen({
    Key? key,
    required this.recipeName,
    required this.nutritionFacts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$recipeName Nutrition Facts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: nutritionFacts.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              trailing: Text(entry.value.toStringAsFixed(2)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
