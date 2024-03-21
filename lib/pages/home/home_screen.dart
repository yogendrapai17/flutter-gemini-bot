import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/pages/stream-response/stream_response_screen.dart';
import 'package:flutter_gemini_chatbot/pages/text-response/text_response_screen.dart';

//const String _apiKey = String.fromEnvironment('API_KEY');

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const StreamResponseScreen();
  }
}
