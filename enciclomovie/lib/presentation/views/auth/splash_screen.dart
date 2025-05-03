import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static const name = 'splash-screen';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/splash/launch_image.png',
          fit: BoxFit.cover, // Adapta completamente la imagen
        ),
      ),
    );
  }
}
