import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/pages/home/home_screen.dart';
import 'package:flutter_gemini_chatbot/pages/stream-response/stream_response_screen.dart';
import 'package:flutter_gemini_chatbot/pages/text-response/text_response_screen.dart';
import 'package:go_router/go_router.dart';

import 'pages/splash/splash_screen.dart';

void main() async {
  runApp(const GeminiBotApp());
}

class GeminiBotApp extends StatelessWidget {
  const GeminiBotApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gemini Chatbot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          primary: Colors.yellow[800],
          seedColor: const Color.fromARGB(255, 171, 222, 244),
        ),
        useMaterial3: true,
      ),
      routerConfig: GoRouter(
        initialLocation: '/splash',
        routes: <RouteBase>[
          GoRoute(
            path: '/splash',
            builder: (BuildContext context, GoRouterState state) {
              return const SplashScreen();
            },
          ),
          GoRoute(
            path: '/home',
            builder: (BuildContext context, GoRouterState state) {
              return const HomeScreen();
            },
          ),
          GoRoute(
            path: '/search',
            builder: (BuildContext context, GoRouterState state) {
              return const StreamResponseScreen();
            },
          ),
          GoRoute(
            path: '/chat',
            builder: (BuildContext context, GoRouterState state) {
              return const TextResponseScreen();
            },
          ),
        ],
      ),
    );
  }
}
