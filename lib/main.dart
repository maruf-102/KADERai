import 'package:chat_app/consts.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/home_page.dart';
import 'package:flutter_gemini/flutter_gemini.dart';


void main() {
  Gemini.init(apiKey: 'AIzaSyAWGsI9MYNSpQwDSD9PRiE7muf_jcKzcuI');
  runApp(const MyApp());
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