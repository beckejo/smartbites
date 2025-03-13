import 'package:flutter/material.dart';
import 'scan_ingredient_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'New Meal',
          style: TextStyle(
                fontFamily: 'Inter Tight',
                color: Colors.white,
                fontSize: 22,
                letterSpacing: 0.0,
              ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Material(
              color: Colors.transparent,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add an ingredient',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'Inter Tight',
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          _navigateToScanIngredientScreen();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ), 
                        icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                        label: const Text('Scan Ingredient Barcode',
                          style: TextStyle(
                            fontFamily: 'Inter Tight',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Material(
              color: Colors.transparent,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ingredients List',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'Inter Tight',
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView(
                        padding: EdgeInsets.zero,
                        primary: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: _ingredients.map((ingredient) {
                          return 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      ingredient['description'] ?? 'Unknown',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                    )
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                    color: Theme.of(context).colorScheme.primary,
                                    onPressed: () {
                                      setState(() {
                                        _ingredients.remove(ingredient);
                                      });
                                    },
                                  ),
                                  SizedBox(width: 8),
                                ],
                              )
                            );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _finishRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                fixedSize: Size(MediaQuery.sizeOf(context).width, 50),
              ), 
              child: const Text('Finish Recipe',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:() {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                fixedSize: Size(MediaQuery.sizeOf(context).width, 50),
              ), 
              child: const Text('Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
