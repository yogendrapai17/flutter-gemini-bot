import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/pages/home/home_provider.dart';
import 'package:flutter_gemini_chatbot/pages/home/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'pages/splash/splash_screen.dart';

void main() async {
  //runApp(const MyApp());

  runApp(const GeminiApp());

  // For text-only input, use the gemini-pro model
  // final model = GenerativeModel(
  //     model: Globals.geminiProModel, apiKey: Globals.geminiAPIKey);

  // final content = [Content.text('Write a story about a magic backpack.')];
  // final response = await model.generateContent(content);
  // debugPrint(response.text);
}

class GeminiApp extends StatelessWidget {
  const GeminiApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProvider()),
      ],
      child: MaterialApp.router(
        title: 'Gemini Chatbot',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
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
          ],
        ),
      ),
    );
  }
}