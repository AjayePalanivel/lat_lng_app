import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lat_lng_app/repository/background_service.dart';
import 'package:lat_lng_app/screens/home_screen.dart';
import 'package:lat_lng_app/screens/landing_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (!await FlutterBackgroundService().isRunning()) {
    await BackgroundService.initializeService();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget displayPage = const LandingScreen();
  int countInternetMessage = 0;
  @override
  void initState() {
    super.initState();
    _checkInternetService();
  }

  void _checkInternetService() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      countInternetMessage = 0;
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          displayPage = const HomeScreen();
        });
      });
    } else {
      if (countInternetMessage == 0) {
        Fluttertoast.showToast(msg: 'No Internet Connection');
        countInternetMessage++;
      }
      Future.delayed(const Duration(seconds: 2), () {
        _checkInternetService();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: displayPage,
    );
  }
}
