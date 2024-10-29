import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Scan extends StatefulWidget {
  const Scan({super.key, required this.updateSelectedDevice});

  final void Function(BluetoothDevice) updateSelectedDevice;

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  // For Bluetooth availability
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  // For BLE scanning
  List<BluetoothDevice> _systemDevices = [];
  List<BluetoothDevice> _scannedDevice = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  // For BLE connection
  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    // Check for BLE availability
    _adapterStateSubscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });

    // Scan subscription
    _scanResultsSubscription =
        FlutterBluePlus.scanResults.listen((List<ScanResult> results) async {
      if (results.isEmpty) {
        return;
      }
      _scannedDevice
        ..clear()
        ..addAll(results.map((ScanResult result) => result.device));

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _adapterStateSubscription.cancel();
    _scanResultsSubscription.cancel();
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text("Scanned Devices"),
            children: _scannedDevice
                .map((BluetoothDevice device) => SimpleDialogOption(
                      onPressed: () {
                        widget.updateSelectedDevice(device);
                      },
                      child: Text(device.advName == ""
                          ? device.remoteId.toString()
                          : device.advName),
                    ))
                .toList(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          if (_adapterState != BluetoothAdapterState.on) {
            return;
          }
          // Scan for BLE devices
          _dialogBuilder(context);
          try {
            await FlutterBluePlus.startScan(
                // withNames: ["UART Service"],
                timeout: const Duration(seconds: 10));
          } catch (e) {
            print(e);
          }
        },
        child: const Text("Scan for BLE devices"));
  }
}
