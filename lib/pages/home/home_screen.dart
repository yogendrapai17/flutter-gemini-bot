import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//const String _apiKey = String.fromEnvironment('API_KEY');

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        children: [
          const Text(
            "Hi, \nWelcome to \nSuper Genie!",
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36.0),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Image.asset("assets/images/super_genie.png"),
          ),
          const Text("Lets see what you came for",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24.0)),
          const SizedBox(height: 36.0),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).push('/search');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[800],
              foregroundColor: Colors.black,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            child: const Text('Text Input Search'),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).push("/chat");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[800],
              foregroundColor: Colors.black,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            child: const Text('Chat with Genie'),
          )
        ],
      ),
    );
  }
}
