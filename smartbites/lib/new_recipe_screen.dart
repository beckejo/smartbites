import 'package:flutter/material.dart';
import 'scan_ingredient_screen.dart';
import 'ingredient_detail_screen.dart';

class NewRecipeScreen extends StatefulWidget {
  const NewRecipeScreen({super.key});

  @override
  _NewRecipeScreenState createState() => _NewRecipeScreenState();
}

class _NewRecipeScreenState extends State<NewRecipeScreen> {
  final List<Map<String, dynamic>> _ingredients = [];

  void _navigateToScanIngredientScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanIngredientScreen()),
    );

    if (result != null) {
      setState(() {
        _ingredients.add(result);
      });
    }
  }

  void _finishRecipe() async {
    final TextEditingController recipeNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Recipe Name'),
          content: TextField(
            controller: recipeNameController,
            decoration: const InputDecoration(
              labelText: 'Recipe Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, recipeNameController.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    final recipeName = recipeNameController.text;
    if (recipeName.isNotEmpty) {
      // Save the recipe with the ingredients list
      // For now, just print the recipe name and ingredients
      print('Recipe saved: $recipeName with ingredients: $_ingredients');
      Navigator.pop(context, {'name': recipeName, 'ingredients': _ingredients});
    }
  }

  void _showWeightEditDialog(int index) {
    final ingredient = _ingredients[index];
    final double currentWeight = ingredient['grams'] as double? ?? 0.0;
    final TextEditingController weightController = TextEditingController(
        text: currentWeight.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Ingredient Weight'),
          content: TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Weight (g)',
              suffixText: 'g',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final inputWeight = double.tryParse(weightController.text) ?? currentWeight;
                // Round to 1 decimal place
                final roundedWeight = (inputWeight * 10).round() / 10;
                setState(() {
                  _ingredients[index]['grams'] = roundedWeight;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: _ingredients.isEmpty
                  ? Center(
                      child: Text(
                        'No ingredients added yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.separated(
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemCount: _ingredients.length,
                      itemBuilder: (context, index) {
                        final ingredient = _ingredients[index];
                        final double grams = ingredient['grams'] as double? ?? 0.0;
                        
                        return Dismissible(
                          key: Key(index.toString()),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16.0),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            setState(() {
                              _ingredients.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Ingredient removed'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    setState(() {
                                      _ingredients.insert(index, ingredient);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IngredientDetailScreen(ingredient: ingredient),
                                ),
                              );
                              setState(() {});
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
                                  // Weight in grams with edit button
                                  InkWell(
                                    onTap: () => _showWeightEditDialog(index),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${grams.toStringAsFixed(1)} g',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.edit, size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            if (_ingredients.isEmpty)
              // Single button when no ingredients
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _navigateToScanIngredientScreen,
                  label: Row(
                    mainAxisSize: MainAxisSize.min, // Prevents row from taking more space than needed
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                        child: Text(
                          'Add Ingredient',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  icon: const Icon(Icons.add_circle, color: Colors.white, size: 20),
                ),
              )
            else
              // Two buttons with equal width when ingredients exist
              Column(
                mainAxisSize: MainAxisSize.max,
                spacing: 10.0,
                children: [
                  OutlinedButton.icon(
                    onPressed: _navigateToScanIngredientScreen,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),

                    ),
                    label: Flexible(
                      child: Text(
                        'Add Ingredient',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    icon: const Icon(Icons.add_circle, size: 20),
                  ),
                  ElevatedButton.icon(
                    onPressed: _finishRecipe,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50)
                    ),
                    label: Flexible(
                      child: Text(
                        'Finish Recipe',
                        overflow: TextOverflow.ellipsis,)
                    ),
                    icon: Icon(Icons.check_circle, color: Colors.white),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
