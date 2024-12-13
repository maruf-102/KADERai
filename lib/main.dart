import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/home_page.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'pomodoro_timer_model.dart'; // Import the Pomodoro Timer model

void main() {
  Gemini.init(apiKey: 'AIzaSyAWGsI9MYNSpQwDSD9PRiE7muf_jcKzcuI');
  runApp(
    ChangeNotifierProvider(
      create: (context) => PomodoroTimerModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KADERai',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black87),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
