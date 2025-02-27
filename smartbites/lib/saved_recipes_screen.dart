import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'recipe_detail_screen.dart'; // new import

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  _SavedRecipesScreenState createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  List<Map<String, dynamic>> _savedRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadSavedRecipes();
  }

  Future<void> _loadSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRecipesString = prefs.getString('savedRecipes') ?? '[]';
    setState(() {
      _savedRecipes =
          List<Map<String, dynamic>>.from(json.decode(savedRecipesString));
    });
  }

  Future<void> _deleteRecipe(int index) async {
    setState(() {
      _savedRecipes.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedRecipes', json.encode(_savedRecipes));
  }

  void _navigateToRecipeDetailsScreen(
      BuildContext context, Map<String, dynamic> recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _savedRecipes.isEmpty
          ? const Center(child: Text('No recipes saved yet.'))
          : ListView.builder(
              itemCount: _savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _savedRecipes[index];
                final recipeTitle = recipe['name'] ?? 'Untitled Recipe';
                return Dismissible(
                  key: Key(recipeTitle),
                  onDismissed: (direction) {
                    _deleteRecipe(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$recipeTitle deleted')),
                    );
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(recipeTitle),
                    onTap: () =>
                        _navigateToRecipeDetailsScreen(context, recipe),
                  ),
                );
              },
            ),
    );
  }
}
