import 'package:flutter/material.dart';

class IngredientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ingredient;

  const IngredientDetailScreen({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    // Assume the ingredient map contains a 'grams' field and a 'nutrients' list.
    final double grams = ingredient['grams'] as double? ?? 0;
    final List<Map<String, dynamic>> nutrients =
        List<Map<String, dynamic>>.from(
      ingredient['nutrients'] ?? [],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(ingredient['description'] ?? 'Ingredient Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Grams: ${grams.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: nutrients.isNotEmpty
                  ? ListView.builder(
                      itemCount: nutrients.length,
                      itemBuilder: (context, index) {
                        final nutrient = nutrients[index];
                        final double value = nutrient['value'] as double;
                        final String name = nutrient['nutrientName'] as String;
                        final String unit = nutrient['unitName'] as String;
                        return ListTile(
                          title: Text(
                            '$name: ${value.toStringAsFixed(2)} $unit',
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('No nutrient data available')),
            ),
          ],
        ),
      ),
    );
  }
}
