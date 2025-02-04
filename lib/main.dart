import "dart:async";

import 'package:flutter/material.dart';
import "package:flutter_compass/flutter_compass.dart";
import "package:geolocator/geolocator.dart";

import "package:gps_compass/widgets/ble.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GpsCompass(),
    );
  }
}

class GpsCompass extends StatefulWidget {
  const GpsCompass({super.key});

  @override
  State<GpsCompass> createState() => _GpsCompassState();
}

class _GpsCompassState extends State<GpsCompass> {
  late StreamSubscription<Position> _positionStream;
  late StreamSubscription<CompassEvent> _compassStream;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
  );
  bool _serviceEnabled = false;
  bool _GeolocationPermissionGranted = false;
  bool _OrientationPermissionGranted = false;
  @override
  void initState() {
    super.initState();

    Future(
      () async {
        _serviceEnabled = await Geolocator.isLocationServiceEnabled();

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          return;
        }
        if (permission != LocationPermission.denied) {
          setState(() {
            _GeolocationPermissionGranted = true;
          });
          return;
        }

        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.denied) {
          setState(() {
            _GeolocationPermissionGranted = true;
          });
          return;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BLEWidget(),
            _GeolocationPermissionGranted
                ? StreamBuilder<Position>(
                    stream: Geolocator.getPositionStream(
                        locationSettings: locationSettings),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      Position? position = snapshot.data;

                      if (position == null) {
                        return const Text("Unknown");
                      }

                      return Text(
                          "Position: ${position.latitude}, ${position.longitude}");
                    },
                  )
                : const Text("Permission not granted"),
            StreamBuilder(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                double? direction = snapshot.data!.heading;

                if (direction == null) {
                  return const Text("No sensors!");
                }

                return Text("Direction: $direction");
              },
            )
          ],
        ),
      ),
    );
  }
}
