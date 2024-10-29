import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Connect extends StatefulWidget {
  const Connect(
      {super.key,
      required this.selectedDevice,
      required this.updateConnectionState,
      required this.updateCharacteristic,
      required this.updateServices});
  final BluetoothDevice selectedDevice;
  final void Function(bool) updateConnectionState;
  final void Function(BluetoothCharacteristic?) updateCharacteristic;
  final void Function(List<BluetoothService>) updateServices;

  @override
  State<Connect> createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  @override
  void initState() {
    super.initState();

    // Connect to the selected device
    widget.selectedDevice.connect(autoConnect: true, mtu: null);
    _connectionStateSubscription =
        widget.selectedDevice.connectionState.listen((state) async {
      widget.updateConnectionState(state == BluetoothConnectionState.connected);
      if (state == BluetoothConnectionState.connected) {
        List<BluetoothService> services =
            await widget.selectedDevice.discoverServices();
        widget.updateServices(services);

        services.forEach((service) {
          service.characteristics.forEach((characteristic) {
            if (characteristic.uuid.str ==
                "6e400002-b5a3-f393-e0a9-e50e24dcca9e") {
              widget.updateCharacteristic(characteristic);
            }
          });
        });
      }
      if (state == BluetoothConnectionState.disconnected) {
        widget.updateCharacteristic(null);
        await widget.selectedDevice.connect(autoConnect: true, mtu: null);
        print("Reconnecting...");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectionStateSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.selectedDevice.advName == ""
        ? widget.selectedDevice.remoteId.toString()
        : widget.selectedDevice.advName);
  }
}
