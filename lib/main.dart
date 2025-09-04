// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/sorteos_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Sorteos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SorteosListPage(),
    );
  }
}
