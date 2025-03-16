import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'new_recipe_screen.dart';
import 'saved_recipes_screen.dart';
import 'recipe_detail_screen.dart'; // Add this line to import RecipeDetailScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBites',
      theme: _buildAppTheme(),
      home: const MyHomePage(title: 'SmartBites'),
      debugShowCheckedModeBanner: false,  // Add this line to remove the debug banner
    );
  }
  
  ThemeData _buildAppTheme() {
    // Define primary and accent colors according to specifications
    const primaryColor = Color(0xFF509a41);    // Primary green
    const darkGreenColor = Color(0xFF186031);  // Dark accent
    const lightGreenColor = Color(0xFF79c367); // Light accent
    const errorColor = Color(0xFFD32F2F);      // Error red
    const backgroundColor = Color(0xFFFFFFFF); // White background
    
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: lightGreenColor,
        tertiary: darkGreenColor,
        error: errorColor,
        background: backgroundColor,
        surface: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.black87,
        onSurface: Colors.black87,
      ),
      
      // Typography
      textTheme: const TextTheme(
        // Headings - 24pt, bold
        displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        // Subheadings - 18pt, medium
        displayMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
        // Body text - 14pt, regular
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black87),
        // Captions - 12pt, light
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.black87),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(120, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(120, 48),
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        errorStyle: const TextStyle(color: errorColor, fontSize: 12),
      ),
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        toolbarHeight: 56,
      ),
      
      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // ListTile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: primaryColor,
        size: 24,
      ),
      
      // Scaffold background color
      scaffoldBackgroundColor: backgroundColor,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      _savedRecipes = List<Map<String, dynamic>>.from(json.decode(savedRecipesString));
    });
  }

  Future<void> _saveRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('savedRecipes', json.encode(_savedRecipes));
  }

  void _navigateToNewRecipeScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/new-recipe'),
        builder: (context) => const NewRecipeScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _savedRecipes.add(result);
      });
      await _saveRecipes();
      
      // Navigate to the recipe details screen for the newly created recipe
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailScreen(
            recipe: result,
            showNutritionFacts: true,  // This will trigger auto-display of nutrition facts
          ),
        ),
      );
    }
  }

  void _navigateToSavedRecipesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/saved-recipes'),
        builder: (context) => const SavedRecipesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access theme text styles
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/sb_logo.png',
                height: 120,  // Adjust size as needed
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to SmartBites',
                style: textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Effortless Nutrition Tracking - No More Guesswork',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _navigateToNewRecipeScreen,
                icon: const Icon(Icons.add),
                label: const Text('New Recipe'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _navigateToSavedRecipesScreen,
                icon: const Icon(Icons.book),
                label: const Text('Saved Recipes'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
