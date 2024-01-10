import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lat_lng_app/screens/home_page.dart';
import 'package:lat_lng_app/screens/landing_screen.dart';
import 'package:lat_lng_app/widgets/app_notification.dart';

void main() async {
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelGroupKey: 'lat_lng_channel_group',
      channelKey: 'LatLngApp Channel',
      channelName: 'LatLngApp Notification',
      channelDescription: 'LatLngApp Notification Channel',
    )
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: 'lat_lng_channel_group',
        channelGroupName: 'lat_lng_group')
  ]);
  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Widget initialWidget;
  int messageCount = 0;
  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
        onNotificationCreatedMethod:
            AppNotification.onNotificationCreatedMethod,
        onDismissActionReceivedMethod:
            AppNotification.onNotificationDismissedMethod,
        onNotificationDisplayedMethod:
            AppNotification.onNotificationDisplayedMethod,
        onActionReceivedMethod: AppNotification.onActionReceivedMethod);
    initialWidget = const LandingScreen();
    Timer(const Duration(seconds: 1), () {
      _checkInternetConnection();
    });
  }

  Future<void> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        initialWidget = HomePage(result: connectivityResult);
      });
    } else {
      if (messageCount == 0) {
        AwesomeNotifications().createNotification(
            content: NotificationContent(
          id: 1,
          channelKey: 'LatLngApp Channel',
          title: 'Check Internet Status',
          body: 'Hey! You gone offline. Please check your internet connection.',
        ));
        Fluttertoast.showToast(msg: 'No Internet Connection');
        messageCount++;
      }
      Timer(const Duration(seconds: 2), () {
        _checkInternetConnection();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Latitude and Longitude App',
      theme: ThemeData(useMaterial3: true),
      home: initialWidget,
    );
  }
}
