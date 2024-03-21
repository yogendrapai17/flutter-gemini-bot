import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      GoRouter.of(context).go("/home");
    });

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.black,
            Colors.grey,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/splash_logo.png",
              width: MediaQuery.of(context).size.width * 0.75,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: CircularProgressIndicator(
                color: Colors.yellow[800],
              ),
            )
          ],
        ),
      ),
    );
  }
}
