import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: size.width,
          width: size.width - 100,
          child: Image.asset('asserts/undraw_my_location_re_r52x.png'),
        ),
      ),
    );
  }
}
