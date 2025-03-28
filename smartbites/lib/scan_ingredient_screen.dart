import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barcode_scan2/barcode_scan2.dart';
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
  bool showManualEntry = false;

  Future<void> fetchFoodData(String upc) async {
    if (upc.isNotEmpty && int.tryParse(upc) != null) { 
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
    else {
      setState(() {
        foodItem = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid UPC code.')),
      );
    }
  }

  Future<void> scanBarcode() async {
    // Launch the barcode scanner and show the live camera preview
    var scanResult = await BarcodeScanner.scan();
    if (scanResult.rawContent.isNotEmpty) {
      String upcCode = scanResult.rawContent;
      
      // Remove leading zero if it's a 13-digit code starting with 0
      // (converts EAN-13 format to UPC-A format)
      if (upcCode.length == 13 && upcCode.startsWith('0')) {
        upcCode = upcCode.substring(1);
      }
      
      setState(() {
        upcController.text = upcCode;
      });
      fetchFoodData(upcCode);
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
        // Use toDouble() instead of direct cast
        final value = (nutrient['value'] as num).toDouble();
        final adjustedValue = (value / 100) * weightUsed;
        return {
          'nutrientName': nutrient['nutrientName'],
          'value': adjustedValue,
          'unitName': nutrient['unitName'],
        };
      }).toList();

      // Push the Ingredient Summary screen and wait for its return.
      final ingredient = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IngredientSummaryScreen(
            description: foodItem!['description'],
            nutrients: List<Map<String, dynamic>>.from(adjustedNutrients),
            grams: weightUsed,
          ),
        ),
      );

      if (ingredient != null) {
        // Return the scanned ingredient to the previous screen.
        Navigator.pop(context, ingredient);
      } else {
        // If the user canceled, clear state so they can scan another.
        setState(() {
          upcController.clear();
          foodItem = null;
        });
      }
    }
  }

  void toggleManualEntry() {
    setState(() {
      showManualEntry = !showManualEntry;
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.8;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ingredient'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Camera scan button
              SizedBox(
                width: buttonWidth,
                height: 60,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 28,
                    color: Colors.white,
                  ),
                  label: const Text('Scan Barcode', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: scanBarcode,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Manual entry button
              SizedBox(
                width: buttonWidth,
                height: 60,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.keyboard,
                    size: 28,
                    color: Colors.white,
                  ),
                  label: const Text('Enter UPC Manually', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: toggleManualEntry,
                ),
              ),
              
              // Conditional manual entry section
              if (showManualEntry) ...[
                const SizedBox(height: 30),
                SizedBox(
                  width: buttonWidth,
                  child: TextField(
                    controller: upcController,
                    decoration: const InputDecoration(
                      labelText: 'UPC Code',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: buttonWidth,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => fetchFoodData(upcController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Fetch Data', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
