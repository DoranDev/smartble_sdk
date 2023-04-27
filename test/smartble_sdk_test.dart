import 'package:flutter_test/flutter_test.dart';
import 'package:smartble_sdk/smartble_sdk.dart';
import 'package:smartble_sdk/smartble_sdk_platform_interface.dart';
import 'package:smartble_sdk/smartble_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSmartbleSdkPlatform
    with MockPlatformInterfaceMixin
    implements SmartbleSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SmartbleSdkPlatform initialPlatform = SmartbleSdkPlatform.instance;

  test('$MethodChannelSmartbleSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSmartbleSdk>());
  });

  test('getPlatformVersion', () async {
    SmartbleSdk smartbleSdkPlugin = SmartbleSdk();
    MockSmartbleSdkPlatform fakePlatform = MockSmartbleSdkPlatform();
    SmartbleSdkPlatform.instance = fakePlatform;

    expect(await smartbleSdkPlugin.getPlatformVersion(), '42');
  });
}
