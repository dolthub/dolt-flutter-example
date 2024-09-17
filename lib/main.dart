import 'package:flutter/material.dart';
import 'package:dolt_flutter_example/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dolt Flutter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 41, 227, 193)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Dolt Flutter Example Home Page'),
    );
  }
}
