import 'dart:async';

import 'package:flutter/services.dart';

class SmartbleSdk {
  static const MethodChannel _channel = MethodChannel('smartble_sdk');

  ///scan(BluetoothDevice device)
  Future<dynamic> scan() => _channel.invokeMethod('scan');

  ///connect(BluetoothDevice device)
  Future<dynamic> connect({required String bname, required String bmac}) =>
      _channel.invokeMethod('connect', {'bname': bname, 'bmac': bmac});

  static const EventChannel _scanChannel = EventChannel('smartble_sdk/scan');

  ///getDeviceListStream(BluetoothDevice device)
  static Stream<dynamic> get getDeviceListStream {
    return _scanChannel.receiveBroadcastStream().cast();
  }
}
