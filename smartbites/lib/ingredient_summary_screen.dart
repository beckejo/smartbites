import 'package:flutter/material.dart';

class IngredientSummaryScreen extends StatelessWidget {
  final String description;
  final List<Map<String, dynamic>> nutrients;

  const IngredientSummaryScreen({
    super.key,
    required this.description,
    required this.nutrients,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: nutrients.length,
                itemBuilder: (context, index) {
                  final nutrient = nutrients[index];
                  final roundedValue =
                      (nutrient['value'] as double).toStringAsFixed(2);
                  return ListTile(
                    title: Text(
                      '${nutrient['nutrientName']}: $roundedValue ${nutrient['unitName']}',
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'description': description,
                  'nutrients': nutrients,
                });
              },
              child: const Text('Add'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
