import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weight_measurement_screen.dart';
import 'ingredient_summary_screen.dart';

class ScanIngredientScreen extends StatefulWidget {
  const ScanIngredientScreen({super.key});

  @override
  _ScanIngredientScreenState createState() => _ScanIngredientScreenState();
}

class _ScanIngredientScreenState extends State<ScanIngredientScreen> {
  final TextEditingController upcController = TextEditingController();
  Map<String, dynamic>? foodItem;

  Future<void> fetchFoodData(String upc) async {
    const apiKey = 'lbjPLUiSxa5yYaxPJX1QgXuNR2pjqNcYfJOQwoeM';
    final searchUrl = 'https://api.nal.usda.gov/fdc/v1/foods/search';
    final params = {
      'api_key': apiKey,
      'query': upc,
    };

    final uri = Uri.parse(searchUrl).replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['foods'].isNotEmpty) {
        setState(() {
          foodItem = data['foods'][0];
        });
        navigateToWeightMeasurementScreen();
      } else {
        setState(() {
          foodItem = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No food items found for this UPC code.')),
        );
      }
    } else {
      setState(() {
        foodItem = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error retrieving data from USDA API.')),
      );
    }
  }

  void navigateToWeightMeasurementScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeightMeasurementScreen(),
      ),
    );

    if (result != null) {
      final weightUsed = result as double;
      final adjustedNutrients =
          (foodItem!['foodNutrients'] as List<dynamic>).map((nutrient) {
        final value = nutrient['value'];
        final adjustedValue = (value / 100) * weightUsed;
        return {
          'nutrientName': nutrient['nutrientName'],
          'value': adjustedValue,
          'unitName': nutrient['unitName'],
        };
      }).toList();

      // Include weightUsed as 'grams' in the ingredientData
      final ingredientData = {
        'description': foodItem!['description'],
        'nutrients': List<Map<String, dynamic>>.from(adjustedNutrients),
        'grams': weightUsed,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IngredientSummaryScreen(
            description: foodItem!['description'],
            nutrients: List<Map<String, dynamic>>.from(adjustedNutrients),
          ),
        ),
      ).then((result) {
        if (result != null) {
          Navigator.pop(context, ingredientData);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ingredient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: upcController,
              decoration: const InputDecoration(
                labelText: 'UPC',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => fetchFoodData(upcController.text),
              child: const Text('Fetch Data'),
            ),
          ],
        ),
      ),
    );
  }
}
