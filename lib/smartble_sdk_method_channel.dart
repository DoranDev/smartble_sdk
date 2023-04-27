import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'smartble_sdk_platform_interface.dart';

/// An implementation of [SmartbleSdkPlatform] that uses method channels.
class MethodChannelSmartbleSdk extends SmartbleSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('smartble_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
