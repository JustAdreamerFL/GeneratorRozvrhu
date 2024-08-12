import 'package:flutter/material.dart';
import 'package:rozvrh_generator/generator_V1.5.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system, // Use system theme
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 123, 132, 159),
        brightness: Brightness.light,
      ),

      darkTheme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 123, 132, 159),
        brightness: Brightness.dark,
      ),
      home: const GeneratorRozvrhu(),
    );
  }
}
