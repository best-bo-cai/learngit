// lib/main.dart
import 'package:flutter/material.dart';
import 'features/chat/chat_screen.dart';

void main() {
  runApp(const EdgeMindApp());
}

class EdgeMindApp extends StatelessWidget {
  const EdgeMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EdgeMind AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      home: const ChatScreen(),
    );
  }
}
