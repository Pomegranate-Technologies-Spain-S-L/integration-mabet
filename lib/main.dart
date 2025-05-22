import 'package:flutter/material.dart';
import 'package:rommaana_form/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Define your custom red color
    const Color primaryRed = Color(0xFFEF4444); // A nice red, similar to #ef4444

    return MaterialApp(
      title: 'Rommana',
      theme: ThemeData(
        // Generate a color scheme based on your primary red color
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          // You can further customize specific colors if needed
          primary: primaryRed, // Ensure primary is your desired red
          onPrimary: Colors.white, // Text/icons on primary color
          surface: Colors.white, // Default surface color for cards, sheets etc.
          onSurface: Colors.black87, // Text/icons on surface color
          background: Colors.white, // Background color for general UI
          onBackground: Colors.black87, // Text/icons on background color
          secondary: primaryRed.withOpacity(0.8), // A slightly lighter red for secondary elements
          outline: Colors.grey.shade300, // Light grey for borders
        ),
        // Set the default scaffold background to white
        scaffoldBackgroundColor: Colors.white,

        // Customize AppBar theme
        appBarTheme: AppBarTheme(
          backgroundColor: primaryRed, // AppBar background will be your red
          foregroundColor: Colors.white, // AppBar text/icon color
          elevation: 4.0, // Add a subtle shadow
        ),

        // Customize Card theme for light grey borders and white background
        cardTheme: CardThemeData(
          color: Colors.white, // Card background is white
          elevation: 2.0, // Default elevation for cards
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
            side: BorderSide(
              color: Colors.grey.shade300, // Light grey border
              width: 1.0,
            ),
          ),
          margin: EdgeInsets.zero, // Default margin, can be overridden by Padding
        ),

        // Customize Input Field (TextFormField, DropdownButtonFormField) theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true, // Fields will have a fill color
          fillColor: Colors.grey.shade50, // Very light grey background for input fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners for input fields
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0), // Light grey border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: primaryRed, width: 2.0), // Red border when focused
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0), // Red border for errors
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700), // Label text color
          hintStyle: TextStyle(color: Colors.grey.shade500), // Hint text color
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),

        // Customize ElevatedButton theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed, // Button background is your red
            foregroundColor: Colors.white, // Button text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners for buttons
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        // Customize SwitchListTile theme
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryRed; // Red when selected
            }
            return Colors.grey.shade400; // Grey when unselected
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryRed.withOpacity(0.5); // Lighter red track when selected
            }
            return Colors.grey.shade200; // Lighter grey track when unselected
          }),
        ),

        // Set default font family (optional, but good for consistency)
        fontFamily: 'Roboto', // Or 'Inter' if you prefer a different common font
      ),
      home: const MyHomePage(title: 'Rommana'),
    );
  }
}

