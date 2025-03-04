import 'package:flutter/material.dart';
import 'package:rozvrh_generator/generated_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system, // Use system theme
      theme: ThemeData(
        sliderTheme: const SliderThemeData(year2023: false),
        colorSchemeSeed: const Color.fromARGB(255, 123, 132, 159),
        brightness: Brightness.light,
      ),

      darkTheme: ThemeData(
        sliderTheme: const SliderThemeData(year2023: false),
        colorSchemeSeed: const Color.fromARGB(255, 123, 132, 159),
        brightness: Brightness.dark,
      ),
      home: const UIGeneratorRozvrhu(),
    );
  }
}
