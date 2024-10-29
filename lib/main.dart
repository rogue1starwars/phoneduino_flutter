import "dart:async";

import 'package:flutter/material.dart';
import "package:flutter_compass/flutter_compass.dart";
import "package:geolocator/geolocator.dart";
import "package:gps_compass/widgets/connect.dart";
import "package:gps_compass/widgets/scan.dart";

import "package:permission_handler/permission_handler.dart";

import "package:gps_compass/widgets/ble.dart";

import "package:flutter_blue_plus/flutter_blue_plus.dart";

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
  final Map<String, double> _destination = {
    "latitude": 35.6730314,
    "longitude": 139.6859365
  };
  final Map<String, double> _currentLocation = {"latitude": 0, "longitude": 0};
  double _destinationBearing = 0;
  bool _serviceEnabled = false;
  bool _GeolocationPermissionGranted = false;
  bool _OrientationPermissionGranted = false;
  BluetoothDevice? selectedDevice;
  bool connected = false;
  List<BluetoothService> services = [];
  BluetoothCharacteristic? characteristic;

  double direction = 0;

  void updateSelectedDevice(BluetoothDevice device) {
    setState(() {
      selectedDevice = device;
    });
  }

  void updateConnectionState(bool connected) {
    setState(() {
      this.connected = connected;
    });
  }

  void updateServices(List<BluetoothService> services) {
    setState(() {
      this.services = services;
    });
  }

  void updateCharacteristic(BluetoothCharacteristic? characteristic) {
    print("Characteristic updated: $characteristic");
    setState(() {
      this.characteristic = characteristic;
    });
  }

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
            TextField(
                decoration: const InputDecoration(
                    labelText: "Latitude",
                    hintText: "Input Latitude",
                    border: OutlineInputBorder()),
                onChanged: (text) {
                  setState(() {
                    try {
                      _destination["latitude"] = double.parse(text);
                    } catch (e) {}
                  });
                }),
            TextField(
                decoration: const InputDecoration(
                    labelText: "Longitude",
                    hintText: "Input Longitude",
                    border: OutlineInputBorder()),
                onChanged: (text) {
                  setState(() {
                    _destination["longitude"] = double.parse(text);
                  });
                }),
            Text(
                "Destination: ${_destination["latitude"]}, ${_destination["longitude"]}"),
            Text("Destination Bearing: $_destinationBearing"),
            Scan(updateSelectedDevice: updateSelectedDevice),
            selectedDevice != null
                ? Connect(
                    selectedDevice: selectedDevice!,
                    updateConnectionState: updateConnectionState,
                    updateCharacteristic: updateCharacteristic,
                    updateServices: updateServices,
                  )
                : const Text("No device selected"),
            connected
                ? TextButton(
                    onPressed: () {
                      Timer.periodic(new Duration(milliseconds: 100),
                          (timer) async {
                        if (characteristic != null) {
                          if (connected) {
                            try {
                              setState(() {
                                _destinationBearing = Geolocator.bearingBetween(
                                    _currentLocation["latitude"] ?? 0.0,
                                    _currentLocation["longitude"] ?? 0.0,
                                    _destination["latitude"] ?? 0.0,
                                    _destination["longitude"] ?? 0.0);
                              });
                              String instruction;
                              if (_destinationBearing == null) {
                                instruction = '0';
                              } else if (direction == null) {
                                instruction = '0';
                              } else {
                                final bearingDifference =
                                    (direction - _destinationBearing) % 360;
                                print(bearingDifference);
                                if (bearingDifference < 20) {
                                  instruction = '1';
                                } else if (bearingDifference > 180) {
                                  instruction = '2';
                                } else {
                                  instruction = '3';
                                }
                              }
                              characteristic!.write(instruction.codeUnits);
                            } catch (e) {
                              print(e);
                              // set timeout
                            }
                          }
                        }
                      });
                    },
                    child: const Text("Send something"))
                : const Text("Not connected"),
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

                      _currentLocation["latitude"] = position.latitude;
                      _currentLocation["longitude"] = position.longitude;
                      // if (characteristic != null) {
                      //   if (connected) {
                      //     characteristic!
                      //         .write(position.latitude.toString().codeUnits);
                      //   }
                      // }

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

                if (snapshot.data!.heading == null) {
                  return const Text("No sensors!");
                }
                direction = snapshot.data!.heading!;

                return Text("Direction: $direction");
              },
            )
          ],
        ),
      ),
    );
  }
}
