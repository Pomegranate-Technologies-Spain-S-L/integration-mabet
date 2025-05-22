import 'package:flutter/material.dart';
import 'package:rommaana_form/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFEF4444);

    return MaterialApp(
      title: 'Rommana',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          primary: primaryRed,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
          background: Colors.white,
          onBackground: Colors.black87,
          secondary: primaryRed.withOpacity(0.8),
          outline: Colors.grey.shade300,
        ),
        scaffoldBackgroundColor: Colors.white,

        appBarTheme: AppBarTheme(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 4.0,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
          margin: EdgeInsets.zero,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: primaryRed, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryRed;
            }
            return Colors.grey.shade400;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryRed.withOpacity(0.5);
            }
            return Colors.grey.shade200;
          }),
        ),

        fontFamily: 'Roboto',
      ),
      home: const MyHomePage(title: 'Rommana'),
    );
  }
}

