import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEWidget extends StatefulWidget {
  const BLEWidget({super.key});

  @override
  State<BLEWidget> createState() => _BLEWidgetState();
}

class _BLEWidgetState extends State<BLEWidget> {
  // For Bluetooth availability
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;
  String text_temp = "supported";

  // // For BLE scanning
  // BluetoothDevice? _scannedResult;
  // List<BluetoothDevice> _systemDevices = [];
  // late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  // // For BLE connection
  // late StreamSubscription<BluetoothConnectionState>
  //     _connectionStateSubscription;

  Future<void> _initBLE() async {
    if (await FlutterBluePlus.isSupported == false) {
      setState(() {
        text_temp = "Not supported";
      });
      return;
    }

    // Check for BLE availability
    // _adapterStateSubscription =
    //     FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
    //   print(state);
    //   _adapterState = state;
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
  }

  @override
  initState() {
    super.initState();

    _initBLE();

    // _scanResultsSubscription =
    //     FlutterBluePlus.scanResults.listen((List<ScanResult> results) async {
    //   print("results");
    //   print("results: $results");
    //   if (results.isEmpty) {
    //     return;
    //   }
    //   _scannedResult = results[0].device;
    //   if (mounted) {
    //     setState(() {});
    //   }
    //   await results[0].device.connect(autoConnect: true, mtu: null);
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });

    // // FlutterBluePlus.cancelWhenScanComplete(_scanResultsSubscription);

    // if (_scannedResult != null) {
    //   _connectionStateSubscription =
    //       _scannedResult!.connectionState.listen((state) {
    //     if (state == BluetoothConnectionState.disconnected) {
    //       _scannedResult!.connect(autoConnect: true, mtu: null);
    //       print("Reconnecting...");
    //     }
    //   });
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _adapterStateSubscription.cancel();
    // _scanResultsSubscription.cancel();
  }

  // Future onScanPressed() async {
  //   try {
  //     await FlutterBluePlus.startScan(timeout: const Duration(seconds: 1));
  //   } catch (e) {
  //     print(e);
  //   }
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  // Future onSearchCharacteristics() async {
  //   List<BluetoothService> services = await _scannedResult!.discoverServices();
  //   services.forEach((service) {
  //     print("Service: ${service.uuid}");
  //     service.characteristics.forEach((characteristic) async {
  //       print(characteristic.uuid);
  //       print("Characteristic: ${characteristic.runtimeType}");
  //       try {
  //         if (characteristic.uuid.str ==
  //             "6e400002-b5a3-f393-e0a9-e50e24dcca9e") {
  //           print("Writing...");
  //           await (characteristic as BluetoothCharacteristic)
  //               .write([0x12, 0x34]);
  //         }
  //       } catch (e) {
  //         print(e);
  //       }
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () async {
            // if (_adapterState != BluetoothAdapterState.on) {
            //   return;
            // }
            // Scan for BLE devices
            // try {
            //   await FlutterBluePlus.startScan(
            //       withNames: ["UART Service"],
            //       timeout: const Duration(seconds: 10));
            // } catch (e) {
            //   print(e);
            // }
            // if (mounted) {
            //   setState(() {});
            // }
          },
          child: Text(
            _adapterState == BluetoothAdapterState.on
                ? "Bluetooth is on"
                : "Bluetooth is off",
            style: TextStyle(fontSize: 24),
          ),
        ),
        Text(text_temp),
        // Text(_scannedResult == null
        //     ? "No device found"
        //     : _scannedResult!.remoteId.str),
        // TextButton(
        //     onPressed: onSearchCharacteristics,
        //     child: Text("Search Characteristics")),
      ],
    );
  }
}
