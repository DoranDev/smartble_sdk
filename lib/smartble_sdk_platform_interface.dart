import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'smartble_sdk_method_channel.dart';

abstract class SmartbleSdkPlatform extends PlatformInterface {
  /// Constructs a SmartbleSdkPlatform.
  SmartbleSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmartbleSdkPlatform _instance = MethodChannelSmartbleSdk();

  /// The default instance of [SmartbleSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelSmartbleSdk].
  static SmartbleSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SmartbleSdkPlatform] when
  /// they register themselves.
  static set instance(SmartbleSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
