import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final ConnectivityResult result;
  const HomePage({super.key, required this.result});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int messageCount = 0;
  late String internet;
  String location = 'none';
  late StreamSubscription<ServiceStatus> _serviceStatusStreamSubscription;

  @override
  void initState() {
    super.initState();
    initializer();
  }

  Future<void> initializer() async {
    internet = widget.result == ConnectivityResult.mobile
        ? 'mobile'
        : widget.result == ConnectivityResult.wifi
            ? 'wifi'
            : 'none';
    requestLocationPermission();
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg:
                'You have Denied location permission. To continue change the permission and restart the app');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'You have Denied Forever location permission. To continue change the permission and restart the app');
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _serviceStatusStreamSubscription =
          Geolocator.getServiceStatusStream().listen((event) {
        if (event == ServiceStatus.disabled) {
          AwesomeNotifications().createNotification(
              content: NotificationContent(
            id: 1,
            channelKey: 'LatLngApp Channel',
            title: 'Check Location Status',
            body:
                'Hey! You GPS is turned off. Please check your Location service.',
          ));
        }
      });
      _checkInternetConnection();
    }
  }

  Future<void> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (messageCount == 1) {
        messageCount = 0;
      }
      Timer(const Duration(seconds: 1), () async {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        await sendLatLng(
                latitude: position.latitude, longitude: position.longitude)
            .catchError((e) {
          print(e);
        });
        _checkInternetConnection();
      });
    } else {
      if (messageCount == 0) {
        AwesomeNotifications().createNotification(
            content: NotificationContent(
          id: 1,
          channelKey: 'LatLngApp Channel',
          title: 'Check Network Status',
          body: 'Hey! You gone offline. Please check your internet connection.',
        ));
        Fluttertoast.showToast(msg: 'No Internet Connection');
        messageCount++;
      }
      Timer(const Duration(seconds: 1), () {
        _checkInternetConnection();
      });
    }
  }

  Future<void> sendLatLng(
      {required double latitude, required double longitude}) async {
    print(latitude);
    print(longitude);
    await http.post(
        Uri.parse('https://machinetest.encureit.com/locationapi.php'),
        body: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString()
        });
  }

  @override
  void dispose() {
    _serviceStatusStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 250,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              // child: Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Lat',
              //       style: Theme.of(context).textTheme.bodyLarge,
              //     ),
              //     Text(
              //       'Lng',
              //       style: Theme.of(context)
              //           .textTheme
              //           .bodyLarge!
              //           .copyWith(fontWeight: FontWeight.bold),
              //     ),
              //   ],
              // ),
            ),
          ),
        ),
      ),
    );
  }
}
